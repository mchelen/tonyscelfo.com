#!/bin/bash
set -e

./_build.sh
/home/tonys/src/google_appengine/google_appengine/appcfg.py --oauth2 update .
