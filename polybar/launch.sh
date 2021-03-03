#!/bin/bash

# Terminate already running bar instance(s).
killall -q polybar


# Wait until the processes have been shut down
while pgrep -x polybar > /dev/null; do sleep 1; done


# Add divider in log file.
echo "------------------------------" 2>&1 | cat >> /tmp/polybar.log


# Launch bar(s)
for m in $(polybar --list-monitors | cut -d":" -f1); do
	MONITOR=$m polybar --reload --config=$HOME/.config/polybar/config.ini mybar 2>&1 | cat >> /tmp/polybar.log &
done


# Sleep for a second.
# If calling from a terminal instance,
# cleans up the output.
sleep 1
