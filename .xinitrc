#!/bin/sh

setxkbmap -option terminate:ctrl_alt_bksp
xbindkeys &
sh ~/.fehbg & 
#exec cwm
#exec wmfs
#exec stumpwm
#exec /usr/bin/subtle &> $HOME/.config/subtle/logs/subtle-$(date +"%F-%k-%M").log
exec subtle
