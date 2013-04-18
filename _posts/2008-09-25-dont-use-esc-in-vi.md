---
title: Don't use the Esc key in Vi
layout: post
alias: /2008/09/dont-use-esc-in-vi.html
---

Emacs or Vi... that's another conversation. But if you are like me and you use Vi, here is a tip that I just learned today.

You can hit Ctrl-c to exit insert mode instead of hitting Esc.

I don't know why it took me 5 years of exclusive Vi use to figure this out, but now that I know... I hope I can help someone else.

A while back I figured out that you can hit Ctrl-\[ to exit insert mode. Ctrl-\[ is definitely better for your hand than Esc, but its not natural so it never stuck. I hit Ctrl-c all time to exit things... again... no idea why it took so long to figure this out.

*update 7/17/09* - After using Ctrl-c for several months now, I have noticed only one major difference between hitting either Esc or Ctrl-\[ compared to hitting Ctrl-c.  If you start a chain of commands in edit mode, then enter insert mode, then exit using Ctrl-c, you will break the chain.  For example... if you hit '80i', then type a character, then hit Esc or Ctrl-\[, Vi will happily repeat your character 80 times.  If you hit '80i', then type a character, then hit Ctrl-c, Vi will only type the character once.
