#/bin/sh
#
# status.sh

ICONS="/home/ethan/.config/wmfs/icons/stat"
DATE=`date "+%I:%M %a %d %b"`
VOL=`amixer | grep "PCM" -A 5 | grep -o "\[.*%" | sed "s/\[//"`
SDD=$(df -h / | awk '/\/$/ {print $3}')
TEMP=$(acpi -t | awk '{print $4}' | cut -d. -f1)
CPU=`top -n2 -d0.1 | grep "Cpu" | awk {'print $2'} | cut -d. -f1 | tail -n1`
BATSTAT=$(acpi | awk '{print $4}' | tr -d '%,')
STATE=`cat /proc/acpi/battery/BAT1/info | grep present | awk '{print $2}'`
free="`cat /proc/meminfo | grep MemFree | cut -d: -f2 | cut -dk -f1`" 
total="`cat /proc/meminfo | grep MemTotal | cut -d: -f2 | cut -dk -f1`" 
MEM=$(echo "scale=5; 100-($free/$total*100)" | bc -l | cut -d. -f1)

if [ $STATE = "no" ]
then
   BAT="\i[1175;6;8;8;$ICONS/ac_01.png]\ \s[1190;14;#D4D4D4;$STATE]\ "
else
   BAT="\i[1170;6;8;8;$ICONS/bat_full_02.png]\ \s[1180;14;#D4D4D4;$BATSTAT%]\ "
fi

wmfs -s "\i[1000;6;8;8;$ICONS/temp.png]\ \s[1020;14;#D4D4D4;$TEMP]\ \i[1050;6;8;8;$ICONS/cpu.png]\ \s[1065;14;#D4D4D4;$CPU]\ \i[1080;6;8;8;$ICONS/mem.png]\ \s[1100;14;#D4D4D4;$MEM%]\ \i[1125;6;8;8;$ICONS/fs_01.png]\ \s[1140;14;#D4D4D4;$SDD]\ $BAT \i[1215;6;8;8;$ICONS/spkr_01.png]\ \s[1227;14;#D4D4D4;$VOL]\ \i[1252;6;8;8;$ICONS/clock.png]\ \s[1265;14;#D4D4D4;$DATE]\ "

