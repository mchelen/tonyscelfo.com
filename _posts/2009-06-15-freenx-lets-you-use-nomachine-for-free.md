---
title: FreeNX lets you use NoMachine for free... and its so nice!!!
layout: default
alias: /2009/06/freenx-lets-you-use-nomachine-for-free.html
---

*UPDATE: This post has been superseded by [my post about NoMachine Free Edition](http://blog.tonyscelfo.com/2009/07/use-nomachine-free-edition-instead-of.html). I'm leaving this post here to avoid duplicating the information about OS X and the reasons to recompile from source.*

[NoMachine NX](http://www.nomachine.com/) is a fantastic suite of server and client tools that allow you to use a remote computer as if the keyboard, mouse and monitor in front of you are plugged directly into the remote machine machine you are connected to. The killer feature is that the session works just like the command line screen program where you can detach and reattach to a full X session.

[FreeNX](http://freenx.berlios.de/) is a GPL implementation of the NX Server and NX Client Components which are normally licensed by NoMachine. I've used both FreeNX and the licensed product by NoMachine. The licensed one is a little snappier and smoother, but for personal use you can't beat free.

The best part is that getting it all working is super easy. Here is what you need to do in ubuntu:

1. Add the following apt sources to your /etc/apt/sources.list file (replace VERSION with either dapper, hardy, intrepid or jaunty:

    deb http://ppa.launchpad.net/freenx-team/ppa/ubuntu VERSION main
    deb-src http://ppa.launchpad.net/freenx-team/ppa/ubuntu VERSION main

2. Get the public key of the FreeNX repo by running `sudo apt-key adv --recv-keys --keyserver keyserver.ubuntu.com 2a8e3034d018a4ce`
3. Update your package cache: `sudo apt-get update`
4. Install FreeNX: `sudo apt-get install freenx`
5. Create the nx system user: `sudo /usr/lib/nx/nxsetup --install`
6. If your server is accessible from the world (not behind a firewall) make sure that you update the NX ssh keys from the default. Follow the instructions for [Using custom SSH keys](https://help.ubuntu.com/community/FreeNX#Using%20custom%20SSH%20keys)
7. On the client: go to the [NX client download page](http://www.nomachine.com/download.php) and download your client from the "NX Client Products" section
8. Install the client, run it and put in the server address and log in information

Like magic, the NX client will connect to your machine over SSH, set up a session and you'll be good to go.

I've used both the mac client and the windows client. The windows client just works. The mac client uses the X11 application in OS X which is horribly broken by default. I recommend downloading [xquartz](http://xquartz.macosforge.org/) which you can quickly download from the [xquartz page on version tracker](http://www.versiontracker.com/dyn/moreinfo/macosx/10912185). The main improvement is that copy/paste (actually) works using a Pasteboard (check the application preferences for settings), but there are a number of other improvements and additional preferences.

Unfortunately, the OS X client needs a little more love if you want to have the command key in OS X map to the alt key in linux... like it really should. This can be done by making a file (I call mine ~/.Xmodmap_osx) with the following contents:

    keycode 63 = Alt_L
    keycode 71 = Alt_R
    keycode 66 = Super_L
    keycode 69 = Super_R
    clear mod1
    clear mod2
    add mod1 = Alt_L
    add mod1 = Alt_R
    add mod4 = Super_L
    add mod4 = Super_R
    keycode 75 = asterisk
    keycode 77 = plus

Then you simply run `xmodmap ~/.Xmodmap_osx` every time you connect to your session from OS X. Its annoying, but I just made a quick menu item in FVWM (my window manager) to execute the xmodmap command.

There are a few essential keybindings to use in NX:
* ctrl-alt-t: bring up a dialog to detach from the session (or terminate if you want to kill it)
* ctrl-alt-f: switch to full screen mode

The only problem I have with NX (and its a big one) is that the key bindings are hard coded into the server binary. For example, there is no setting on either the client or the server that lets you change ctrl-alt-t to be something else. This is especially annoying for me since my FVWM configuration uses ctrl-alt-j which NX captures to force a screen refresh, thus preventing FVWM from getting that key event. However, this can be worked around by editing the source code for NX. The commands are as follows:
1. Create a directory for working with apt source packages (if you don't have one already) and cd into it
2. Run `apt-get source nxagent-source` (creates "nxagent-" directory)
3. Run apt-get source nxagent (creates "nx-x11-" directory)
4. Edit nxagent-/programs/Xserver/hw/nxagent/Keystroke.c and look for the nxagentCheckSpecialKeystroke function.
5. Take out the ones that you don't want or change them to something else.
6. From inside the nxagent- directory, run `dpkg-buildpackage -rfakeroot -uc -b`
7. From the apt source packages directory run `dpkg -i nxagent_.deb`
8. From inside the nx-X11- directory, run `dpkg-buildpackage -rfakeroot -uc -b`... it will likely complain about missing source dependencies, just install the packages dependencies you need.
9. From the apt source packages directory run `dpkg -i nx-x11_.deb`
10. Run `sudo /etc/init.d/freenx-server restart`

After doing all those steps you will have overwritten the nxagent binary with a version you built with your own keybindings. Its kind of a pain, but its worth doing it so you can use your precious keybindings.

If you connect from OS X 10.4, then you will see that the mouse cursor is yellow.  That is a bug in the X11 server shipped with 10.4.  Get the [yellow cursor fix](http://www.lycestra.com/Home/X11.html) and update your X11 server to get a normal cursor back that won't be impossible to find on a white background.
