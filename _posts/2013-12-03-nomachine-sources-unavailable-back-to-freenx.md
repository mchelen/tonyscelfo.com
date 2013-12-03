---
title: The NoMachine sources aren't available anymore, back to FreeNX
layout: post
---

{% highlight bash %}

$ sudo apt-get install freenx-server
$ mkdir ~/src/nxagent
$ cd ~/src/nxagent
$ sudo apt-get build-dep nxagent
$ apt-get source nxagent
$ cd nxagent-*
$ curl -L http://tonyscelfo.com/dl/nx/Keystore.c.patch | patch -p1
$ curl -L http://tonyscelfo.com/dl/nx/Cursor.c.patch | patch -p1
$ dpkg-source --commit . cursor_warp_and_keyboard_binding_change
$ dpkg-buildpackage
$ cd ..
$ sudo dpkg -i nxagent_*.deb

{% endhighlight %}
