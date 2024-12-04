#!/usr/bin/env lua

local grid = {}

for line in io.lines() do
    if #line == 0 then break end
    local row = {}
    for c in line:gmatch(".") do table.insert(row, c) end

    table.insert(grid, row)
end

local part1_word = {'X', 'M', 'A', 'S'}
local part2_word = {'M', 'A', 'S'}

local function scan_line(pos_x, pos_y, direction, word)
    local word_idx = 1
    while pos_x >= 1 and pos_x <= #grid[1] and
          pos_y >= 1 and pos_y <= #grid and
          word_idx <= #word do

        if grid[pos_y][pos_x] ~= word[word_idx] then break end

        pos_x = pos_x + direction[1]
        pos_y = pos_y + direction[2]
        word_idx = word_idx + 1
    end

    return word_idx > #word
end

local function scan_cross(pos_x, pos_y, direction)
    return scan_line(pos_x-direction[1], pos_y-direction[2], direction, part2_word)
end

local directions = {
    {1, 0}, --right
    {1, 1}, --rightdown
    {0, 1}, --down
    {-1, 1}, --leftdown
    {-1, 0}, --left
    {-1, -1}, --leftup
    {0, -1}, --up
    {1, -1}, --rightup
}

local cross_directions = {
    {1, 1}, --rightdown
    {-1, 1}, --leftdown
    {-1, -1}, --leftup
    {1, -1}, --rightup
}

local num_matches = 0

--part 1

--[[
for y=1, #grid do
    for x=1, #grid[1] do
        --print(string.format("loooooop, x: %d, y: %d, char: %s", x, y, grid[y][x]))
        if grid[y][x] == 'X' then
            for _, direction in ipairs(directions) do
                local found = scan_line(x, y, direction, part1_word)
                num_matches = num_matches + (found and 1 or 0)
            end

        end
    end
    --print()
end
--]]

--part 2
for y=2, #grid-1 do
    for x=2, #grid[1]-1 do
        if grid[y][x] == 'A' then
            if (scan_cross(x, y, cross_directions[1]) or scan_cross(x, y, cross_directions[3])) and
               (scan_cross(x, y, cross_directions[2]) or scan_cross(x, y, cross_directions[4])) then
                num_matches = num_matches + 1
            end
        end
    end
end

print(num_matches)