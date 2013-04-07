---
title: Use Smarthost to Route Outgoing Exim4 Mail Through Gmail
layout: default
alias: /2009/07/use-smarthost-to-route-outgoing-exim4.html
---

*Update 8/27/12* - [Ubuntu 12.04](http://releases.ubuntu.com/12.04/) installs postfix by default.  If you want to use postfix instead of exim4, follow [these instructions](http://blog.bigdinosaur.org/postfix-gmail-and-you/).  I'm running 12.04 now and using postfix.

Frustration combined with information found [here](http://www.glorat.net/2008/11/ubuntu-804-hardy-gmail-smarthost-setup-with-exim4.html) inspired this post.

I run an Ubuntu server at home and I have several monitoring tools running to keep an eye on services and hardware. For example: smartd emails me when there are hard drive errors, mdadm emails me when there are raid array problems and monit emails me when services die and get restarted.

Recently, my Ubuntu server hasn't been able to send emails to my gmail account. I looked at the `/var/log/exim4/mainlog` and saw a lot of entries about "R=dnslookup T=remote_smtp defer (110): Connection timed out". The remote SMTP server was failing to validate the hostname of my server, which isn't valid outside of my home network. Since I have Comcast at home, there isn't any chance that I could get a reverse DNS entry so the best solution is to use Exim4's smarthost mail routing feature to route outgoing mail through a gmail account. Google will use the gmail login and password to authenticate my home server and then relay email through Google's own SMTP servers.

You could use your own gmail account for routing the email, but if you use [Google Apps](http://www.google.com/a) on your own domain, a better solution is to create a new email account to use for sending mail from your server. This allows you to isolate your automated emails from your primary email account while also protecting your gmail account's password. You could use common account names like "postmaster" and "noreply" or something else that isn't likely to get slammed with spam. Gmail will keep a copy of the sent messages in the Sent Mail folder, which is a cool side effect.

Sounds too good to be true? Ready to jump in?

First run `sudo dpkg-reconfigure exim4-config` and use these config options:

* General type of mail configuration: mail sent by smarthost; received via SMTP or fetchmail

* System mail name: &lt;your hostname&gt;

* IP-address to listen on for incoming SMTP connections: 127.0.0.1

* Other destinations for which mail is accepted: &lt;your hostname&gt;

* Machines to relay mail for: &lt;leave this blank&gt;

* IP address or host name of the outgoing smarthost: smtp.gmail.com::587

* Hide local mail name in outgoing mail?
  * Yes - all outgoing mail will appear to come from your gmail account
  * No - mail sent with a valid sender name header will keep the sender's name

* Keep number of DNS-queries minimal (Dial-on-Demand)? No

* Delivery method for local mail: &lt;choose the one you prefer&gt;

* Split configuration file into small files? Yes (you need to edit one of the files next)

Then run `sudo vi /etc/exim4/passwd.client` and add the following lines (substitute &lt;email address&gt; and &lt;password&gt; with the gmail account you want to route mail through):

    gmail-smtp.l.google.com:<email address>:<password>
    *.google.com:<email address>:<password>
    smtp.gmail.com:<email address>:<password>

Once you edit the passwd.client file, run `sudo update-exim4.conf` which will integrate your changes into your Exim4 config.

Run `sudo /etc/init.d/exim4 restart` and make sure that the service stops and starts properly. If the service is unable to restart, something probably went wrong when you edited the passwd.client file.

If Exim4 restarted, go ahead and run `sudo tail -f /var/log/exim4/mainlog` to watch the mail logs. In a different window, send an email from your system and make sure that you see a record go by with `R=smarthost T=remote_smtp_smarthost H=gmail-smtp-msa.l.google.com ... X=TLS-1.0:RSA_ARCFOUR_MD5:16` in it. The X=TLS means that the mail is being sent with [transport layer security](http://en.wikipedia.org/wiki/Transport_Layer_Security) which is what you want.
