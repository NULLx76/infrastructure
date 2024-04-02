#!/usr/bin/env lua

aw = io.popen("hyprctl monitors | grep active | sed 's/()/(1)/g' | sort | awk 'NR>1{print $1}' RS='(' FS=')'")
active_workspace = aw:read("*a")
aw:close()

box = "(box :orientation \"v\" :spacing 1 :space-evenly \"true\" "

for i = 1,10 do
    if i == tonumber(active_workspace) then
        local btn = "(button :class \"active\" :onclick \"hyprctl dispatch workspace "..i.." \" \"\")"
        box = box .. btn
    else
        local btn = "(button :class \"inactive\" :onclick \"hyprctl dispatch workspace "..i.."\" \"\")"
        box = box .. btn
    end
end

box = box .. ")"

print(box)
