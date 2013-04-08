---
title: Hacking AppleTV
layout: default
alias: /2008/09/hacking-appletv.html
---

The Take 2 update from Apple wipes our customizations that were previously done.  After going through the hassle of hacking Take 2, I decided to make a list of the steps needed to hack a fresh AppleTV with the Take 2 update without opening the case.  What you’ll have when you are done:

1. SSH server on the AppleTV
2. AFP server to transfer files to the AppleTV
3. NFS and SMB clients so your AppleTV can play from network shares
4. The ATVFiles plugin so you can play the files through the onscreen menu

Great guide that will take you through the entire process:

* [Take 2 Full Update Guide](http://wiki.awkwardtv.org/wiki/Take_2_Full_Update)

Steps from the guide and my comments about them:

1. Install AppleTV Take 2 update. (I did a full factory restart and then updated to the latest software update)

2. Use [Patchstick](http://wiki.awkwardtv.org/wiki/Take2patch) to boot the AppleTV off a USB key (I used a 256mb key) and enable SSH. (There wasn’t a Take 2 compatible patchstick when I did this, so I needed to convert an original patchstick by adding some files that were removed from the Take 2 release. This link seems to have taken care of that problem. When the patch is done, the AppleTV tries to reboot and mine kernel panics… just pull out the USB key and power cycle the AppleTV and it should be fine)

3. Install the [ATVFiles](http://ericiii.net/sa/appletv/ATVFiles-1.0.take2b1.run) beta plugin or look in their [Take 2 thread](http://forum.awkwardtv.org/viewtopic.php?f=18&t=1175&sid=d60286cbf432310ca421bcd4db550520) for a newer version. (I’m using the beta 1 release and it is much nicer than the alpha release described in the guide)

4. Install [Perian](http://perian.org/). (If you want wmv support, you cana get [Flip4Mac](http://www.flip4mac.com/), but I don’t use it)

5. Install AFP by using the automatic process in the guide. (This will mount the recovery partition on the AppleTV and pull some files out of it that were left out of the Take 2 release… the afpinstall.sh script takes a little while to run)

6. Reboot AppleTV.

7. Install USB by following the instructions in the guide. This step is the most complicated. (For me, when I ran the “do_usb_patch.sh” script, the patch failed with a bus error because the precompiled kernel patcher didn’t run on my version of OS X. I downloaded the [prelink_tool source](http://www.paulbart.net/AppleTV/prelink_tool.070330a.tgz), extracted it and ran “make” to build it. Once I built my own prelink_tool, I was able to patch the kernel following the instructions in the guide)

8. Install the mount_smbfs binary. (I got the binary out of the MacOS X 10.4.9 Combo Updater mentioned in the guide)

9. Create rc.local. (This step will let the AppleTV load your new kernel extensions when it boots. I copied the kextstat binary from my OS X Tiger installation to the AppleTV so that I could run it to find out which kernel extensions were loaded, but you should only need to do that if you run into problems.  If you don’t have Tiger running, take a look in the Combo Updater from step 8, it might be in there)

10. Reboot AppleTV.

After following those steps, you should be happy with your AppleTV. Well… at least as happy as you can be knowing that things like [Popcorn Hour](http://www.popcornhour.com/) exist.

But what about automatically mounting SMB and NFS shares when AppleTV boots? For that, I’m using an OS X LaunchAgent. If you are familiar with linux startup scripts, you will think that OS X plist startup scripts are crazy. I don’t really like them, but they do allow for some cool things like executing scripts when certain directories are accessed. We’re not going to do any of that, so its a lot of overhead to use a LaunchAgent plist file, but it works.

If you want to mount SMB, you should enable the [setuid bit](http://en.wikipedia.org/wiki/Setuid) on mount_smbfs so that you can inherit root permissions as the default frontrow user.

`bash-2.05b$ sudo chmod +s /sbin/mount_smbfs`

Here are example LaunchAgent files, modify them to fit your application. The Labels that start with com.tonyscelfo are there to be unique, change them to fit your needs. The first program argument of “-t” seems to be needed but I really have no idea why… maybe someone can post an explanation for why that’s needed.

`/Users/frontrow/Library/LaunchAgents/com.tonyscelfo.nfs.plist`

{% highlight xml %}
    <?xml version=”1.0″ encoding=”UTF-8″?>
    <!DOCTYPE plist PUBLIC “-//Apple Computer//DTD PLIST 1.0//EN” “http://www.apple.com/DTDs/PropertyList-1.0.dtd”>
    <plist version=”1.0″>
    <dict>
            <key>Disabled</key>
            <false/>
            <key>Label</key>
            <string>com.tonyscelfo.nfs</string>
            <key>Program</key>
            <string>/sbin/mount_nfs</string>
            <key>ProgramArguments</key>
            <array>
                    <string>-t</string>
                    <string>nfsserver:/path/to/share</string>
                    <string>/Users/frontrow/Movies/NFSMountPath</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>OnDemand</key>
            <false/>
    </dict>
    </plist>
{% endhighlight %}

`/Users/frontrow/Library/LaunchAgents/com.tonyscelfo.smb.plist`

{% highlight xml %}
    <?xml version=”1.0″ encoding=”UTF-8″?>
    <!DOCTYPE plist PUBLIC “-//Apple Computer//DTD PLIST 1.0//EN” “http://www.apple.com/DTDs/PropertyList-1.0.dtd”>
    <plist version=”1.0″>
    <dict>
            <key>Disabled</key>
            <false/>
            <key>Label</key>
            <string>com.tonyscelfo.smb</string>
            <key>Program</key>
            <string>/sbin/mount_smbfs</string>
            <key>ProgramArguments</key>
            <array>
                    <string>-t</string>
                    <string>//username:password@sambaserver/SharePath</string>
                    <string>/Users/frontrow/Movies/SMBMountPath</string>
            </array>
            <key>RunAtLoad</key>
            <true/>
            <key>OnDemand</key>
            <false/>
    </dict>
    </plist>
{% endhighlight %}

Once you put the plist file into the `~/Library/LaunchAgents` directory (which you might need to create), your SMB or NFS mount will automatically get connected when you boot the AppleTV.

Enjoy.
