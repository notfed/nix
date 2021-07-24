#!/bin/sh
# vim:ft=zsh ts=2 sw=2 sts=2
#
#

# NOTE: Must have "command-time" zsh plugin
zsh_command_time() {
    if [ -n "$ZSH_COMMAND_TIME" ]; then
        hours=$(($ZSH_COMMAND_TIME/3600))
        min=$(($ZSH_COMMAND_TIME/60))
        sec=$(($ZSH_COMMAND_TIME%60))
        if [ "$ZSH_COMMAND_TIME" -le 60 ]; then
            timer_show="$fg[046]Δ ${ZSH_COMMAND_TIME}s"
        elif [ "$ZSH_COMMAND_TIME" -gt 60 ] && [ "$ZSH_COMMAND_TIME" -le 180 ]; then
            timer_show="$fg[yellow]Δ ${min}m${sec}s"
        else
            if [ "$hours" -gt 0 ]; then
                min=$(($min%60))
                timer_show="$fg[red]Δ ${hours}h${min}m${sec}s"
            else
                timer_show="$fg[red]Δ ${min}m${sec}s"
            fi
        fi
        #printf "${ZSH_COMMAND_TIME_MSG}\n" "$timer_show"
        printf "$timer_show"
    fi
}

# Must use Powerline font, for \uE0A0 to render.
ZSH_THEME_GIT_PROMPT_PREFIX=" %{$fg[magenta]%}\uE0A0 "
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[red]%}!"
ZSH_THEME_GIT_PROMPT_UNTRACKED="%{$fg[green]%}?"
ZSH_THEME_GIT_PROMPT_CLEAN=""

ZSH_THEME_RUBY_PROMPT_PREFIX="%{$fg_bold[red]%}‹"
ZSH_THEME_RUBY_PROMPT_SUFFIX="›%{$reset_color%}"

PROMPT='
%{$fg_bold[green]%}%~%{$reset_color%}$(git_prompt_info) %{$fg_bold[red]%}⌚%*%{$reset_color%} $(zsh_command_time)
$ '

RPROMPT='$(ruby_prompt_info)'

