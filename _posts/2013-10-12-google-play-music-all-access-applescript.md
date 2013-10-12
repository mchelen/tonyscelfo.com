---
title: Use Applescript to control Google Play Music All Access
layout: post
---

Thanks to the [Create global hotkeys to control Google Music playback ](http://hints.macworld.com/article.php?story=20110622061755509) post from June 23, 2011, I figured out how to control [Google Play Music All Access](https://play.google.com/about/music/) via Applescript.  This is useful because I have a [Griffin PowerMate](http://store.griffintechnology.com/powermate) which can be configured to launch Applescript commands.  Now I can pause/play music and skip to previous/next track my pushing or rotating the powermate.  I had previously done this for the [Mog](http://www.mog.com) OS X application and I wasn't willing to switch to [Google Play Music All Access](https://play.google.com/about/music/) because of the lack of global keyboard bindings.  Now I have them.

The following are adaptations of the script posted on [Create global hotkeys to control Google Music playback ](http://hints.macworld.com/article.php?story=20110622061755509) but I've updated them to be a little more fault tolerant and to work with the current window titles of [Google Play Music All Access](https://play.google.com/about/music/).

{% highlight bash %}
tell application "Google Chrome"
  set allWins to every window
  set allTabs to {}
  repeat with currWin in allWins
    set allTabs to allTabs & every tab of currWin
  end repeat
  set musicTab to null
  repeat with currTab in allTabs
    set currTitle to title of currTab as string
    set currLength to length of currTitle
    if currLength > 13 then
      set suffix to characters -13 thru -1 of currTitle as string
      if suffix = "- Google Play" then
        set musicTab to currTab
      end if
    end if
  end repeat
  if (musicTab is not null) then
    try
      tell musicTab to execute javascript "SJBpost('playPause');" #nextSong, prevSong playPause
    end try
  end if
end tell
{% endhighlight %}
