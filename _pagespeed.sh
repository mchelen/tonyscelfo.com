#!/bin/bash

minify_css_bin=~/src/depot_tools/src/out/Debug/minify_css_bin
minify_html_bin=~/src/depot_tools/src/out/Debug/minify_html_bin
minify_js_bin=~/src/depot_tools/src/out/Debug/minify_js_bin
optimize_image_bin=~/src/depot_tools/src/out/Debug/optimize_image_bin

input_dir=_site
output_dir=_pagespeed

cd $(dirname ${BASH_SOURCE[0]})

rm -rf _pagespeed

for dir in $(find ${input_dir} -type d); do
  mkdir ${dir/${input_dir}/${output_dir}}
done

for file in $(find ${input_dir} -type f); do
  output_file=${file/${input_dir}/${output_dir}}
  if [[ ${file} =~ .css$ ]]; then
    ${minify_css_bin} ${file} ${output_file}
  elif [[ ${file} =~ .html$ ]]; then
    ${minify_html_bin} ${file} ${output_file}
  elif [[ ${file} =~ .js$ ]]; then
    ${minify_js_bin} ${file} ${output_file}
  elif [[ ${file} =~ .png$ ]]; then
    ${optimize_image_bin} -input_file ${file} -output_file ${output_file}
  else
    cp -v ${file} ${output_file}
  fi
done
