#!/bin/bash
set -e
cd $(dirname ${BASH_SOURCE[0]})

minify_css_bin=~/src/depot_tools/src/out/Release/minify_css_bin
minify_html_bin=~/src/depot_tools/src/out/Release/minify_html_bin
minify_js_bin=~/src/depot_tools/src/out/Release/minify_js_bin
optimize_image_bin=~/src/depot_tools/src/out/Release/optimize_image_bin

input_dir=_site
output_dir=_pagespeed

if [ ! -d ${output_dir} ]; then
  echo
  echo "Output directory ${output_dir} doesn't exist."
  echo
  echo "Create one or use a symlink to point elsewhere..."
  echo "for example to a directory served by a web server."
  exit 1
fi

rm -rf ${output_dir}/*

for dir in $(find ${input_dir} -type d); do
  tmp_output_dir=${dir/${input_dir}/${output_dir}}
  if [[ ${tmp_output_dir} != ${output_dir} ]]; then
    mkdir ${tmp_output_dir}
  fi
done

IFS=$'\n'
for file in $(find ${input_dir} -type f); do
  output_file=${file/${input_dir}/${output_dir}}
  if [[ ${file} =~ .css$ ]]; then
    ${minify_css_bin} ${file} ${output_file}
  elif [[ ${file} =~ .html$ ]]; then
    ${minify_html_bin} ${file} ${output_file}
  elif [[ ${file} =~ .js$ ]]; then
    ${minify_js_bin} ${file} ${output_file}
  elif [[ ${file} =~ .jpg$ || ${file} =~ .png$ ]]; then
    ${optimize_image_bin} -input_file ${file} -output_file ${output_file}
  else
    cp -v "${file}" "${output_file}"
  fi
done
