---
title: Use NoMachine Free Edition Instead of FreeNX
layout: post
alias: /2009/07/use-nomachine-free-edition-instead-of.html
---

[FreeNX](http://freenx.berlios.de/) is great and I wrote [this FreeNX post](http://blog.tonyscelfo.com/2009/06/freenx-lets-you-use-nomachine-for-free.html) about it last month. Since then, I've realized that NoMachine offers their own NX server for free as "NoMachine Free Edition" with the limitation that you can only have two simultaneous users connected at a time.

If you are new to NX, I highly recommend reading [my FreeNX post](http://blog.tonyscelfo.com/2009/06/freenx-lets-you-use-nomachine-for-free.html) because it talks more about NX and it describes how to use xmodmap to fix key bindings when using an OS X client to connect to a linux server.

To get started the easy way, visit the [NoMachine Free Edition download page](http://www.nomachine.com/download-3) and download "NX Free Edition for Linux". If you are on Ubuntu, grab the deb file for the server and install it as you normally would.

{% highlight bash %}
$ sudo dpkg -i nxserver_X.Y.Z-N_i386.deb
{% endhighlight %}

If you are happy with the default configuration of NX server, you can stop here. If you are an OS X user or if you want to change some of the NX key bindings you need to recompile nxagent from source. Take a look at [my FreeNX post](http://blog.tonyscelfo.com/2009/06/freenx-lets-you-use-nomachine-for-free.html) to read more about why you might want to recompile.

If recompiling is for you, start by download the source from the [NX source download page](http://www.nomachine.com/NX-OSS-sources).  You can get them all in one shot by running:

{% highlight bash %}
$ contents=$(curl http://www.nomachine.com/NX-OSS-sources) \
  && curl -O $(for file in nxproxy nxcomp nxcompext nxcompshad nx-X11 nxauth nxagent; \
    do echo "${contents}" | egrep "${file}-[0-9]" | grep href | head -n 1 | sed 's/.*href="\(.*\)".*/\1/'; \
  done) \
{% endhighlight %}

Or you can download them one at time.  You'll need these files:

    nxproxy-X.Y.Z-N.tar.gz
    nxcomp-X.Y.Z-N.tar.gz
    nxcompext-X.Y.Z-N.tar.gz
    nxcompshad-X.Y.Z-N.tar.gz
    nx-X11-X.Y.Z-N.tar.gz
    nxauth-X.Y.Z-N.tar.gz
    nxagent-X.Y.Z-N.tar.gz

Unpack the tarballs.

{% highlight bash %}
$ for file in *.gz; do tar xzf ${file}; done
{% endhighlight %}

On Ubuntu, make sure you have the jpeg and png dev libraries installed.

{% highlight bash %}
$ sudo apt-get install libjpeg62-dev libpng12-dev
{% endhighlight %}

(Optional) Modify Keystroke.c to remove some server side keyboard bindings which conflict with my window manager keyboard shortcuts.

{% highlight bash %}
$ curl -O http://tonyscelfo.com/dl/nx/Keystore.c.patch && patch -p0 < Keystore.c.patch
{% endhighlight %}

(Optional) Modify Cursor.c to enable client side cursor warp.  This was removed in the 3.5 line because it caused problems when resizing nxclient sessions.  [NoMachine article about removing cursor warp.](http://www.nomachine.com/ar/view.php?ar_id=AR02J00622)  However, use fvwm2 and have keyboard shortcuts to move my mouse which don't work without client side cursor warp.

{% highlight bash %}
$ curl -O http://tonyscelfo.com/dl/nx/Cursor.c.patch && patch -p0 < Cursor.c.patch
{% endhighlight %}

Go into the nx-X11 directory.

{% highlight bash %}
$ cd nx-X11/
{% endhighlight %}

Build the nxagent binary. The -j12 flag tells make to use eight threads. If you have a multicore system, replace with the number of cores that you have. If you don't have a multicore system, leave the flag out.

{% highlight bash %}
$ make -j12 World
{% endhighlight %}

If the build was successful, you will get a message like: "Full build of Release 6.9 complete."

(Optional) If you want to shrink the nxagent binary by removing debugging information that you likely won't ever need, you can strip it out.

{% highlight bash %}
$ strip programs/Xserver/nxagent
{% endhighlight %}

Replace the binary that was installed from the NoMachine Free Edition install. We'll keep a back up of the original in case something went wrong.

{% highlight bash %}
$ sudo mv /usr/NX/bin/nxagent /usr/NX/bin/nxagent.orig
$ sudo cp -a programs/Xserver/nxagent /usr/NX/bin/nxagent
$ sudo chown root:root /usr/NX/bin/nxagent
$ sudo chmod 755 /usr/NX/bin/nxagent
{% endhighlight %}

Restart the NX server.

{% highlight bash %}
$ sudo /etc/init.d/nxserver restart
{% endhighlight %}

---

This one liner works (inefficiently) to download all the source files:

{% highlight bash %}
$ for file in nxproxy nxcomp nxcompext nxcompshad nx-X11 nxauth nxagent; do url=`curl http://www.nomachine.com/NX-OSS-sources | egrep "${file}-[0-9]" | grep href | head -n 1 | sed 's/.*href="\(.*\)".*/\1/'`; curl -O ${url}; done
{% endhighlight %}

---

If you want to modify Keystroke.c the same way I do (remove some bindings that interfere with my window manager keyboard shortcuts), you can add this step after extracting all the source files:

{% highlight bash %}
$ curl -O http://tonyscelfo.com/dl/nx/Keystore.c.patch && patch -p0 < Keystore.c.patch
{% endhighlight %}

---

In the 3.5 line, the nx team removed client side cursor warp. I need that to use FVWM2 with my keyboard bindings to move the mouse. This command will download source before they removed client side cursor warp:

{% highlight bash %}
$ for file in nxagent-3.5.0-2.tar.gz nxcomp-3.5.0-1.tar.gz nxcompshad-3.5.0-2.tar.gz nx-X11-3.5.0-1.tar.gz nxauth-3.5.0-1.tar.gz nxcompext-3.5.0-1.tar.gz nxproxy-3.5.0-1.tar.gz; do curl -O http://64.34.161.181/download/3.5.0/sources/${file}; done
{% endhighlight %}

---

Do this all in one shot:

{% highlight bash %}
$ sudo apt-get install libjpeg62-dev libpng12-dev \
    && contents=$(curl http://www.nomachine.com/NX-OSS-sources) \
    && curl -O $(for file in nxproxy nxcomp nxcompext nxcompshad nx-X11 nxauth nxagent; \
      do echo "${contents}" | egrep "${file}-[0-9]" | grep href | head -n 1 | sed 's/.*href="\(.*\)".*/\1/'; \
    done) \
    && for file in *.gz; do tar xzf ${file}; done \
    && curl -O http://tonyscelfo.com/dl/nx/Keystore.c.patch && patch -p0 < Keystore.c.patch \
    && curl -O http://tonyscelfo.com/dl/nx/Cursor.c.patch && patch -p0 < Cursor.c.patch \
    && cd nx-X11/ \
    && make -j12 World \
    && strip programs/Xserver/nxagent \
    && sudo mv /usr/NX/bin/nxagent /usr/NX/bin/nxagent.orig \
    && sudo cp -a programs/Xserver/nxagent /usr/NX/bin/nxagent \
    && sudo chown root:root /usr/NX/bin/nxagent \
    && sudo chmod 755 /usr/NX/bin/nxagent \
    && sudo /etc/init.d/nxserver restart
{% endhighlight %}
