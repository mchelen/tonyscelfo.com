---
title: Use AppleScript to control Google Play Music All Access
layout: post
---

Thanks to the [Create global hotkeys to control Google Music playback ](http://hints.macworld.com/article.php?story=20110622061755509) post from June 23, 2011, I figured out how to control [Google Play Music All Access](https://play.google.com/about/music/) via AppleScript.  This is useful because I have a [Griffin PowerMate](http://store.griffintechnology.com/powermate) which can be configured to launch AppleScript commands.  Now I can pause/play music and skip to previous/next track my pushing or rotating the PowerMate.  I had previously done this for the [Mog](http://www.mog.com) OS X application and I wasn't willing to switch to [Google Play Music All Access](https://play.google.com/about/music/) because of the lack of global keyboard bindings.  Now I have them.

The following are adaptations of the script posted on [Create global hotkeys to control Google Music playback ](http://hints.macworld.com/article.php?story=20110622061755509) but I've updated them to be a little more fault tolerant and to work with the latest [Google Play Music All Access](https://play.google.com/about/music/).

{% highlight applescript %}
tell application "Google Chrome"
  repeat with w in (every window)
    repeat with t in (every tab whose URL contains "play.google.com/music") of w
      # Options for action are:
      # 1 = previous
      # 2 = play/pause
      # 3 = next
      set action to 2
      tell t to execute javascript "document.getElementsByClassName('flat-button')[" & action & "].click();"
      return
    end repeat
  end repeat
end tell
{% endhighlight %}

If you want to get this as an [Alfred App](http://www.alfredapp.com/) Workflow, [download it here](/dl/alfred/pause_google_play_music.alfredworkflow).
