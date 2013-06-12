#!/bin/bash
set -e

jekyll build
rm _site/app.yaml
./_pagespeed.sh
