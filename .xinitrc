#!/bin/sh

setxkbmap -option terminate:ctrl_alt_bksp
xbindkeys &

exec wmfs
