#!/bin/sh

setxkbmap -option terminate:ctrl_alt_bksp
#syndaemon -t -k -i 2 -d &
xbindkeys &

pidof mpdscribble >& /dev/null
if [ $? -ne 0 ]; then
  mpdscribble &
fi

sh ~/.fehbg & 

exec /usr/bin/subtle &> $HOME/.config/subtle/logs/subtle-$(date +"%F-%k-%M").log
#exec subtle
