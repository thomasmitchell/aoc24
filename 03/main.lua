#!/usr/bin/env lua

local input = io.read("a")

local sum = 0
local index = 1

while true do
    local front, back = string.find(input, "(don't%(%))", index)
    if not front then back = #input end

    for first, second in string.gmatch(string.sub(input, index, back), "mul%((%d+),(%d+)%)") do
        sum = sum + first * second
    end

    front, back = string.find(input, "(do%(%))", back + 1)
    if not front then break end
    index = back + 1
end

print(sum)