---
title: Use Jekyll with Twitter Bootstrap, PageSpeed and App Engine
layout: post
---

This site is currently built using [Jekyll](http://jekyllrb.com/), [Twitter Bootstrap](http://twitter.github.io/bootstrap/), [PageSpeed](https://developers.google.com/speed/pagespeed/) and is hosted on [App Engine](https://developers.google.com/appengine/).  This is currently my favorite way to easily build and host fast and highly available websites.

All websites work be loading html files from a server.  The fastest possible servers are ones that simply serve static html files instead of running code to dynamically generate the html at request time.  [Jekyll](http://jekyllrb.com/) is a clever tool that precomputes static html files for a website.  It uses [Markdown](http://daringfireball.net/projects/markdown/) as a templating language to simplify the process of writing valid html.  When the `jekyll build` command is executed, it compiles a full set of html pages under a single output directory called `_site/`.  You can serve directly out of the `_site/` directory, rsync it to a remote server or even use [GitHub's free hosting of jekyll pages](https://help.github.com/articles/using-jekyll-with-pages).

I've taken things one step further.  I take the `_site/` output from [Jekyll](http://jekyllrb.com/), use [PageSpeed](https://developers.google.com/speed/pagespeed/) to minify the html, css and images and then publish the static pages to [App Engine](https://developers.google.com/appengine/).  The primary advantage of [App Engine](https://developers.google.com/appengine/) over [GitHub's free hosting of jekyll pages](https://help.github.com/articles/using-jekyll-with-pages) or inexpensive alternatives like [Dreamhost](http://dreamhost.com/) is that Google's hosting is distributed globally from many data centers with extremly high availabiliy and very low network latency... and it's free for up to 10 applications.  CPU intensive applications can run out of the free quota on [App Engine](https://developers.google.com/appengine/) but this example serves static content so it doesn't consume much quota.

  1. Install [Jekyll](http://jekyllrb.com/):

{% highlight bash %}
$ gem install jekyll
{% endhighlight %}

  2. Create a [Jekyll](http://jekyllrb.com/) site using [Twitter Bootstrap](http://twitter.github.io/bootstrap/) by following these great [Using Twitter Bootstrap with Jekyll instructions](http://brizzled.clapper.org/blog/2012/03/05/using-twitter-bootstrap-with-jekyll/).  Follow the instructions until you get to a place where you can run `jekyll build` to generate content in your `_site/` directory.

  3. Build the [PageSpeed](https://developers.google.com/speed/pagespeed/) command line tools using `gclient` from [depot_tools](http://dev.chromium.org/developers/how-tos/depottools):

{% highlight bash %}
$ cd ~/src
$ svn checkout http://src.chromium.org/svn/trunk/tools/depot_tools
$ cd depot_tools/
$ ./gclient config https://page-speed.googlecode.com/svn/lib/trunk/src
$ ./gclient sync
$ cd src/
$ BUILDTYPE=Release make
{% endhighlight %}

  4. Create a script called `_build.sh` with the following contents:

{% highlight bash %}
#!/bin/bash
set -e

# Build the _site/ contents with Jekyll
jekyll build

# Remove the App Engine config file (see step #6)
rm _site/app.yaml

# Process and optize the _site/ contents and copy them to _pagespeed/
./_pagespeed.sh
{% endhighlight %}

  5. Create a script called `_pagespeed.sh` with the following contents:

{% highlight bash %}
#!/bin/bash
set -e

# Paths to the PageSpeed tools compiled in step #3.
minify_css_bin=~/src/depot_tools/src/out/Release/minify_css_bin
minify_html_bin=~/src/depot_tools/src/out/Release/minify_html_bin
minify_js_bin=~/src/depot_tools/src/out/Release/minify_js_bin
optimize_image_bin=~/src/depot_tools/src/out/Release/optimize_image_bin

# The directory where Jekyll outputs files
input_dir=_site
# The directory where PageSpeed optimized files will be placed
output_dir=_pagespeed

# A short way to ensure we're in the working directory where the script
# is stored.  This allows the script to be called from anywhere.
cd $(dirname ${BASH_SOURCE[0]})

# Delete the output directory contents because we'll recreate everything.
rm -rf ${output_dir}/*

# Look at all the directories under the input_dir and create parallel
# directories under the output_dir.
for dir in $(find ${input_dir} -type d); do
  tmp_output_dir=${dir/${input_dir}/${output_dir}}
  if [[ ${tmp_output_dir} != ${output_dir} ]]; then
    mkdir ${tmp_output_dir}
  fi
done

# Look at all the files under the input_dir and pass them through PageSpeed
# on their way into the output_dir or simply copy them if there isn't a
# PageSpeed optimization for that file type.
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
{% endhighlight %}

  6. Create an [App Engine](https://developers.google.com/appengine/) application and use an `app.yaml` config like this.  Note that unlike the other files which can be prefixed with an underscore to be ignored by [Jekyll](http://jekyllrb.com/), [App Engine](https://developers.google.com/appengine/) requires a config file called `app.yaml`:

{% highlight yaml %}
application: <your_application_name>
version: <your_application_version>
runtime: python27
api_version: 1
threadsafe: true

handlers:
- url: /
  static_files: _pagespeed/index.html
  upload: _pagespeed/index.html
- url: /[^\.]* # anything without a .
  script: _app.redirect.wsgi
- url: /(.+)
  static_files: _pagespeed/\1
  upload: _pagespeed/(.+)
{% endhighlight %}

  7. Note the "anything with a ." url handler.  This is a little trick to take any request where the path doesn't contain a period and route it through a simple wsgi redirect handler.  This allows you to handle custom urls like http://tonyscelfo.com/+.  To do that, create an `_app` directory with an empty `__init__.py` file in it so [App Engine](https://developers.google.com/appengine/) recognizes the directory:

{% highlight bash %}
$ mkdir _app
$ touch _app/__init__.py
{% endhighlight %}

  8. Create the redirect handler `_app/redirect.py`:

{% highlight python %}
import webapp2

redirects = {
    '/<:\+|plus>': 'https://plus.google.com/110371866564374610674',
    '/random_path': 'http://some/random/destination'
}

wsgi = webapp2.WSGIApplication(
    [webapp2.Route(
        key,
        webapp2.RedirectHandler,
        defaults={'_uri': redirects[key]})
        for key in redirects.keys()],
    debug=False)
{% endhighlight %}

  9. Finally, create a `_deploy.py` script which you can run to build, optimize and then publish your site to [App Engine](https://developers.google.com/appengine/).  Adjust accordingly to point to the [App Engine](https://developers.google.com/appengine/) client code wherever you installed it:

{% highlight bash %}
#!/bin/bash
set -e

./_build.sh
~/src/google_appengine/appcfg.py --oauth2 update .
{% endhighlight %}
