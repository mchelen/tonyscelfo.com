---
title: Use AppleScript to control Beats Music
layout: post
---

Similar to my post [Use AppleScript to control Google Play Music All Access](/2013/10/12/google-play-music-all-access-applescript.html), here are instructions to use AppleScript to control [Beats Music](https://beatsmusic.com/).  It's so much nicer to have global hotkeys to control music players.  See the [Use AppleScript to control Google Play Music All Access](/2013/10/12/google-play-music-all-access-applescript.html) for some credit for how I figured this all out.  Applying the same technique to [Beats Music](https://beatsmusic.com/) was a lot easier because the DOM element IDs aren't obfuscated.

{% highlight applescript %}
tell application "Google Chrome"
  repeat with w in (every window)
    repeat with t in (every tab whose URL contains "listen.beatsmusic.com") of w
      # Options for ids are:
      # t-prev = previous
      # t-play = play/pause
      # t-next = next
      set elemId to "t-prev"
      tell t to execute javascript "document.getElementById('" & elemId & "').click();"
      return
    end repeat
  end repeat
end tell
{% endhighlight %}
