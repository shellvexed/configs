#!/bin/bash

RC="$HOME/.scripts/conkyrc"
FG="#555555"
BG="#151515"
ALIGN="right"
WIDTH="1166"
HEIGHT="14"
FONT="-*-Terminus-medium-*-*-*-10-*-*-*-*-*-*-*"
XPOS="200" 
YPOS="0"

: "${wm:=monsterwm}"
: "${ff:="/tmp/${wm}.fifo"}"

[[ -p $ff ]] || mkfifo -m 600 "$ff"
while read -r; do
    [[ $REPLY =~ ^(([[:digit:]]+:)+[[:digit:]]+ ?)+$ ]] && read -ra desktops <<< "$REPLY" || continue
for desktop in "${desktops[@]}"; do
IFS=':' read -r d w m c u <<< "$desktop"
        case $d in
            0) d="^i(/home/ethan/.icons_xbm/terminal.xbm)" s="  " ;;
            1) d="^i(/home/ethan/.icons_xbm/world.xbm)" s="  " ;;
            2) d="^i(/home/ethan/.icons_xbm/wrench.xbm)" s="  " ;;
            3) d="^i(/home/ethan/.icons_xbm/screen.xbm)" s="  " ;;
        esac
        ((c)) && f="#b3b3b3" && case $m in
            0) i="^i(/home/ethan/.icons_xbm/tile.xbm)" ;;
            1) i="^i(/home/ethan/.icons_xbm/monocle.xbm)" ;;
            2) i="^i(/home/ethan/.icons_xbm/bstack.xbm)" ;;
            3) i="^i(/home/ethan/.icons_xbm/grid.xbm)" ;;
        esac || f="#7f7f7f"
        ((w)) && r+="$s ^fg($f)$d $w^fg() " || r+="$s ^fg($f)$d^fg() "
    done
printf "%s%s\n" "$r" "   $i" && unset r
done < "$ff" | dzen2 -h $HEIGHT -w 200 -ta l -e -p -fg $FG -bg $BG -fn $FONT &

exec conky -d -c $RC | dzen2 -fg $FG -bg $BG -ta $ALIGN -w $WIDTH -h $HEIGHT -x $XPOS -y $YPOS -fn $FONT &

while :; do "$wm" || break; done | tee -a "$ff"
