#!/bin/bash
set -e
jekyll --no-auto
rm _site/app.yaml
./_pagespeed.sh
