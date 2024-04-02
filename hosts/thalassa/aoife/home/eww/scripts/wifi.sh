#!/bin/sh

if wpa_cli status | rg -q "wpa_state=COMPLETED"; then
    icon="直"
    status="Connected"
else
    icon="睊"
    status="offline"
fi

printf "{\"icon\": \"${icon}\", \"status\": \"${status}\"}" 
