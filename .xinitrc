#!/bin/sh

setxkbmap -option terminate:ctrl_alt_bksp

#syndaemon -t -k -i 2 -d &
#xbindkeys &

sh ~/.fehbg & 
#sh ~/.scripts/dzensh_left &
#sh ~/.scripts/dzensh_right &

#pidof mpdscribble >& /dev/null
#if [ $? -ne 0 ]; then
#  mpdscribble &
#fi
#xsetroot -solid "#151515"

#exec ratpoison
#exec herbstluftwm
#exec monsterwm
sh ~/.scripts/startmonsterwm.sh 
