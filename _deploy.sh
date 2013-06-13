#!/bin/bash
set -e
cd $(dirname ${BASH_SOURCE[0]})

./_build.sh
~/src/google_appengine/appcfg.py --oauth2 update .
