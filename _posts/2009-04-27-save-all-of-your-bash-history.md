---
title: Save all of your bash history
layout: default
alias: /2009/04/save-all-of-your-bash-history.html
---

The greatest workflow change I've made to improve productivity is to save every single command I enter into my terminal.

Just add this snippet into your `~/.bashrc` file and you will get a `~/.bash_eternal_history` file that will contain every command you run. No more worrying about the max size of your bash history file or getting frustrated that the command you wanted to recall was 102 commands ago in a history file with 100 commands.

{% highlight bash %}
    # don't put duplicate lines in the history. See bash(1) for more options
    # ... and ignore same sucessive entries.
    export HISTCONTROL=ignoreboth

    # set the time format for the history file.
    export HISTTIMEFORMAT="%Y.%m.%d %H:%M:%S "

    # If this is an xterm set the title to user@host:dir
    case "$TERM" in
      xterm*|rxvt*)
      # Show the currently running command in the terminal title:
      # http://www.davidpashley.com/articles/xterm-titles-with-bash.html
      show_command_in_title_bar()
      {
        case "$BASH_COMMAND" in
          *\033]0*)
          # The command is trying to set the title bar as well;
          # this is most likely the execution of $PROMPT_COMMAND.
          # In any case nested escapes confuse the terminal, so don't
          # output them.
          ;;
          *)
          if test ! "$BASH_COMMAND" = "log_bash_eternal_history"
          then
            echo -ne "\033]0;$(history 1 | sed 's/^ *[0-9]* *//') :: ${PWD} :: ${USER}@${HOSTNAME}\007"
          fi
          ;;
        esac
      }
      trap show_command_in_title_bar DEBUG
      ;;
      *)
      ;;
    esac

    log_bash_eternal_history()
    {
      local rc=$?
      [[ $(history 1) =~ ^\ *[0-9]+\ +([^\ ]+\ [^\ ]+)\ +(.*)$ ]]
      local date_part="${BASH_REMATCH[1]}"
      local command_part="${BASH_REMATCH[2]}"
      if [ "$command_part" != "$ETERNAL_HISTORY_LAST" -a "$command_part" != "ls" -a "$command_part" != "ll" ]
      then
        echo $date_part $HOSTNAME $rc "$command_part" >> ~/.bash_eternal_history
        export ETERNAL_HISTORY_LAST="$command_part"
      fi
    }

    PROMPT_COMMAND="log_bash_eternal_history"
{% endhighlight %}

In case you are curious about how the magic happens, its just a neat little trick. `PROMPT_COMMAND` is an environment variable that bash reads and executes right before displaying the prompt. Some people use it to dump out the date so they can tell when commands finish running. I'm using it to call the `log_bash_eternal_history()` helper function which does all the magic.
