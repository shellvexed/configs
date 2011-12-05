
# Check for an interactive session
[ -z "$PS1" ] && return

#Export
export EDITOR="vim"

#Aliases
alias grep='grep --color=auto'
alias ls='ls --color=auto'

#PROMPT_COMMAND='usercolor="\[\033[0;36m\]";[[ $EUID == 0 ]] && usercolor="\[\033[1;31m\]";PS1="$(pwd)";PS1="$usercolor\u\[\033[0m\]@\[\033[0;33m\]\h\[\033[0m\]:${PS1//\//$usercolor/\[\033[0m\]}$usercolor\\$\[\033[0m\] "'
PS1='\u \w '
