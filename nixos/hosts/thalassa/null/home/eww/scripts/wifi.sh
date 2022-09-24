#!/bin/sh

if nmcli g | rg -q "\bconnected\b"; then
    icon="直"
    ssid=$(nmcli -t -f name connection show --active | sed -z 's/\n/,/g;s/,$/\n/')
    if echo $ssid | rg -q "Wired"; then
        status="Connected via cable" 
    else
        status="Connected to ${ssid}"
    fi
else
    icon="睊"
    status="offline"
fi

printf "{\"icon\": \"${icon}\", \"status\": \"${status}\"}" 
