#!/bin/bash

cols=`tput cols`
if [ "$cols" -gt "80" ]; then
	cols=80;
fi

space=`echo "($cols - 25)/2" | bc`

for i in `seq $space`; do SP="$SP "; done
echo "$SP _| o  _  |  _ __  _  |  $SP"
echo "$SP(_| | _>  | (_||||(_) |< $SP"
for i in `seq $cols`; do echo -n "-"; done; echo
echo

FILE=$CFG_SCRIPT_DIR/other/quip.list
shuf -n 1 $FILE | fold -w $cols -s; echo

dt=`date`
ll=$(last -1 -R  $USER | head -1 | cut -c 23-)

echo "Last Login: $ll"
echo "Date: $dt"
echo
