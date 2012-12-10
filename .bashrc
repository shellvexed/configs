#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

export EDITOR=vim

alias ls='ls --color=auto'
PS1='[\u@\h \W]\$ '
alias android-connect="sudo mtpfs -o allow_other /media/android"
alias android-disconnect="sudo umount /media/android"
