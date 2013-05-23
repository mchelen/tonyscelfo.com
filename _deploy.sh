#!/bin/bash
set -e
./_build.sh
./_pagespeed.sh
/home/tonys/src/google_appengine/google_appengine/appcfg.py --oauth2 update .
