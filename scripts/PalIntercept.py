"""
This script intercepts the communication content with "api.palworldgame.com".
"""
import os
import stat
import logging

from mitmproxy import http
from mitmproxy.http import Headers

BASEDIR = "/home/steam/autopause"
REGISTER_JSON_PATH = BASEDIR + "/register.json"
UPDATE_JSON_PATH = BASEDIR + "/update.json"

class PalIntercept:
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


addons = [PalIntercept()]
