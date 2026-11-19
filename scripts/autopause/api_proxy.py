import asyncio
import logging
import os
import secrets
from typing import TypeAlias

from fastapi import Depends, FastAPI, HTTPException, Request, Response
from fastapi.security import HTTPBasic, HTTPBasicCredentials
import httpx2 as httpx

app = FastAPI()
logger = logging.getLogger(__name__)
security = HTTPBasic(auto_error=False)

# Definitions
REST_API_PORT = os.getenv("REST_API_PORT", "8212")
TARGET_URL = "http://localhost:" + REST_API_PORT
PAUSED_FILE_PATH = "/palworld/.paused"
RESUME_REQUEST_PATH = "/palworld/.autopause-request"
SERVER_STATUS_PATH = "/palworld/.status"
API_TIMEOUT = 5.0
CACHE_ENDPOINTS = {
    "/v1/api/players",
    "/v1/api/game-data",
    "/v1/api/metrics",
    "/v1/api/info",
    "/v1/api/settings",

    # `POST /v1/api/save` is not an endpoint that would typically be cached.
    # However, because a save operation is triggered just before the system transitions into a "suspended" state, this operation effectively becomes redundant.
    # By including this endpoint in the cache, we prevent the system from "waking up" to perform a pointless save operation.
    "/v1/api/save",
}
SAVE_ENDPOINT = "/v1/api/save"
CACHE_KEY: TypeAlias = tuple[str, str, str, bytes]
HOP_BY_HOP_HEADERS = {
    "connection",
    "content-encoding",
    "content-length",
    "keep-alive",
    "proxy-authenticate",
    "proxy-authorization",
    "te",
    "trailer",
    "transfer-encoding",
    "upgrade",
}

# Data structure for storing cache
cache: dict[CACHE_KEY, dict[str, object]] = {}


async def request_resume() -> None:
    with open(RESUME_REQUEST_PATH, "w") as request_file:
        request_file.write("Resumed by REST API proxy.\n")


async def wait_for_rest_api(timeout: float = API_TIMEOUT) -> bool:
    loop = asyncio.get_running_loop()
    deadline = loop.time() + timeout
    while loop.time() < deadline:
        try:
            _, writer = await asyncio.wait_for(
                asyncio.open_connection("127.0.0.1", int(REST_API_PORT)),
                timeout=min(0.5, max(0.01, deadline - loop.time())),
            )
            writer.close()
            await writer.wait_closed()
            return True
        except (OSError, asyncio.TimeoutError, ValueError):
            await asyncio.sleep(min(0.1, max(0, deadline - loop.time())))
    return False


def require_auth(
    credentials: HTTPBasicCredentials | None = Depends(security),
) -> None:
    configured_password = os.getenv("ADMIN_PASSWORD", "")
    valid_username = credentials is not None and secrets.compare_digest(
        credentials.username, "admin"
    )
    valid_password = (
        credentials is not None
        and bool(configured_password)
        and secrets.compare_digest(credentials.password, configured_password)
    )
    if not valid_username or not valid_password:
        raise HTTPException(
            status_code=401,
            detail="Invalid authentication credentials",
            headers={"WWW-Authenticate": "Basic"},
        )


def cache_key(method: str, path: str, query: str, body: bytes = b"") -> CACHE_KEY:
    return method.upper(), path, query, body


def has_cache_control_directive(request: Request, directive_name: str) -> bool:
    directive_name = directive_name.lower()
    for header_value in request.headers.getlist("cache-control"):
        in_quotes = False
        escaped = False
        start = 0
        for index, character in enumerate(header_value):
            if escaped:
                escaped = False
            elif in_quotes and character == "\\":
                escaped = True
            elif character == '"':
                in_quotes = not in_quotes
            elif character == "," and not in_quotes:
                name, separator, _ = header_value[start:index].partition("=")
                if not separator and name.strip().lower() == directive_name:
                    return True
                start = index + 1

        name, separator, _ = header_value[start:].partition("=")
        if not separator and name.strip().lower() == directive_name:
            return True

    return False


def response_headers(headers: httpx.Headers | dict[str, str]) -> dict[str, str]:
    return {
        key: value
        for key, value in headers.items()
        if key.lower() not in HOP_BY_HOP_HEADERS
    }


def unavailable_response() -> Response:
    return Response(
        content='{"error": "Palworld server is starting up or unreachable"}',
        status_code=503,
        media_type="application/json",
    )


def cached_response(key: CACHE_KEY) -> Response | None:
    cached_res = cache.get(key)
    if cached_res is None:
        return None
    return Response(
        content=cached_res["content"],
        status_code=cached_res["status_code"],
        headers=cached_res["headers"],
    )


def is_cacheable_request(method: str, path: str) -> bool:
    return path in CACHE_ENDPOINTS and (
        (method == "GET" and path != SAVE_ENDPOINT)
        or (method == "POST" and path == SAVE_ENDPOINT)
    )


def only_if_cached_response(
    request: Request, key: CACHE_KEY, cacheable: bool
) -> Response | None:
    if not has_cache_control_directive(request, "only-if-cached"):
        return None
    if request.method == "GET" and cacheable:
        cached_res = cached_response(key)
        if cached_res is not None:
            return cached_res
    return Response(status_code=504)


async def resume_if_paused(
    cacheable: bool, key: CACHE_KEY
) -> tuple[Response | None, float | None]:
    # Check whether the server is paused.
    if not os.path.exists(PAUSED_FILE_PATH):
        return None, None
    if not cacheable:
        return None, None

    cached_res = cached_response(key)
    if cached_res is not None:
        return cached_res, None

    loop = asyncio.get_running_loop()
    resume_deadline = loop.time() + API_TIMEOUT
    try:
        # The resume request wakes the server through the port-knock handler.
        await request_resume()
    except OSError:
        return unavailable_response(), None

    remaining = resume_deadline - loop.time()
    if remaining <= 0 or not await wait_for_rest_api(remaining):
        return unavailable_response(), None
    return None, resume_deadline


async def update_status_after_shutdown(
    method: str, path: str, status_code: int
) -> None:
    if (
        method != "POST"
        or path not in {"/v1/api/shutdown", "/v1/api/stop"}
        or status_code >= 400
    ):
        return

    try:
        status_process = await asyncio.create_subprocess_exec(
            "/bin/bash",
            "/home/steam/server/update_server_status.sh",
            "stopping",
            "10",
            stderr=asyncio.subprocess.PIPE,
        )
        _, status_error = await status_process.communicate()
        if status_process.returncode != 0:
            logger.error(
                "Failed to update server status after shutdown request "
                "(exit code %s): %s",
                status_process.returncode,
                status_error.decode(errors="replace").strip() or "no error output",
            )
    except OSError as exc:
        logger.error("Failed to update server status after shutdown request: %s", exc)


async def forward_request(
    request: Request,
    req_path: str,
    body: bytes,
    key: CACHE_KEY,
    cacheable: bool,
    resume_deadline: float | None,
) -> Response:
    # Forward requests to the REST API.
    url = f"{TARGET_URL}{req_path}"
    if request.url.query:
        url += f"?{request.url.query}"

    async with httpx.AsyncClient() as client:
        try:
            timeout = API_TIMEOUT
            if resume_deadline is not None:
                timeout = resume_deadline - asyncio.get_running_loop().time()
                if timeout <= 0:
                    return unavailable_response()
            resp = await client.request(
                method=request.method,
                url=url,
                headers={
                    key: value
                    for key, value in request.headers.items()
                    if key.lower() != "host"
                },
                content=body,
                timeout=timeout,
            )

            if cacheable and resp.status_code == 200:
                cache[key] = {
                    "content": resp.content,
                    "status_code": resp.status_code,
                    "headers": response_headers(resp.headers),
                }

            await update_status_after_shutdown(
                request.method, req_path, resp.status_code
            )
            return Response(
                content=resp.content,
                status_code=resp.status_code,
                headers=response_headers(resp.headers),
            )
        except httpx.RequestError:
            if cacheable:
                cached_res = cached_response(key)
                if cached_res is not None:
                    return cached_res
            return unavailable_response()


@app.api_route("/proxy/v1/api/status", methods=["GET"])
async def status(_: None = Depends(require_auth)):
    # Endpoint to get the current server status
    # SCHEMA:
    # {
    #     "status": "starting" | "updating" | "running" | "stopping"  | "stopped" | "paused"
    #     "progress": 100
    # }
    if os.path.exists(SERVER_STATUS_PATH):
        with open(SERVER_STATUS_PATH, "r") as f:
            content = f.read()
        return Response(
            content=content,
            status_code=200,
            media_type="application/json",
        )
    else:
        return Response(
            content='{"status": "unknown", "progress": 0}',
            status_code=200,
            media_type="application/json",
        )


@app.api_route("/{path:path}", methods=["GET", "POST", "PUT", "DELETE"])
async def proxy(
    request: Request,
    path: str,
    _: None = Depends(require_auth),
):
    req_path = f"/{path}"
    body = await request.body()
    key = cache_key(request.method, req_path, request.url.query, body)
    cacheable = is_cacheable_request(request.method, req_path)

    cached_only_response = only_if_cached_response(request, key, cacheable)
    if cached_only_response is not None:
        return cached_only_response

    paused_response, resume_deadline = await resume_if_paused(cacheable, key)
    if paused_response is not None:
        return paused_response

    return await forward_request(
        request, req_path, body, key, cacheable, resume_deadline
    )
