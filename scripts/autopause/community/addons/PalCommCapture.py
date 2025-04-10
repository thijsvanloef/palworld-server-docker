"""
This script intercepts the communication content with "api.palworldgame.com".

When a server goes to sleep, it disappears from the community server list.
We need to continue communication on behalf of the sleeping server.
The data needed to continue communication is captured here.

If the communication content changes in future version updates,
please check using the following script.

$ docker exec -it palworld-server cat autopause/community/register.json

"""
import os
import stat
import logging

from mitmproxy import http
from mitmproxy.http import Headers

BASEDIR = "/home/steam/server/autopause/community"
REGISTER_JSON_PATH = BASEDIR + "/register.json"
UPDATE_JSON_PATH = BASEDIR + "/update.json"

class PalCommCapture:
    def __init__(self):
        st = os.stat(BASEDIR)
        self.uid = st.st_uid
        self.gid = st.st_gid

    def response(self, flow: http.HTTPFlow):
        if flow.request.host == "api.palworldgame.com" and flow.request.is_http11 and flow.response.status_code == 200:
            if flow.request.path == "/server/register":
                with open(REGISTER_JSON_PATH, "wb") as f:
                    f.write(flow.request.content)
                os.chown(REGISTER_JSON_PATH, self.uid, self.gid)
            if flow.request.path == "/server/update":
                with open(UPDATE_JSON_PATH, "wb") as f:
                    f.write(flow.request.content)
                os.chown(UPDATE_JSON_PATH, self.uid, self.gid)


addons = [PalCommCapture()]
