#!/usr/bin/env nix-shell
#! nix-shell -p jq -i bash

if makoctl mode | grep -Fxq "do-not-disturb"; then
    eww update dnd=""
    makoctl mode -r do-not-disturb > /dev/null
else
    eww update dnd=""
    makoctl mode -a do-not-disturb > /dev/null
fi
