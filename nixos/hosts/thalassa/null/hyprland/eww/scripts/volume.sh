#!/bin/sh

per="$(pamixer --get-volume)"

if pamixer --get-mute | grep -q true; then
    icon="婢"
elif [ "$per" -gt 66 ]; then
    icon="墳" # high
elif [ "$per" -gt 33 ]; then
    icon="奔" # med
else
    icon="奄" #low
fi

printf "{\"icon\": \"${icon}\", \"percent\": \"${per}\"}" 
