#!/usr/bin/env lua

local function createClass()
    local c = {}
    c.__index = c

    function c:new(o)
        o = o or {}
        setmetatable(o, self)
        return o
    end

    return c
end

--VEC2
local Vec2 = createClass()

function Vec2:add(right_vec)
    self[1] = self[1] + right_vec[1]
    self[2] = self[2] + right_vec[2]
end

function Vec2:sub(right_vec)
    self[1] = self[1] - right_vec[1]
    self[2] = self[2] - right_vec[2]
end

function Vec2:rotateRight()
    local orig_x = self[1]
    self[1] = -self[2]
    self[2] = orig_x
    --third number is evil hack optimization to not have to calc for bitshift
    -- don't @ me
    self[3] = (self[3] + 1) % 4
end

function Vec2:clone()
    return Vec2:new({self[1], self[2], self[3]})
end

function Vec2:eq(right_vec)
    return self[1] == right_vec[1] and self[2] == right_vec[2]
end

DIR_UP = Vec2:new({0, -1, 0})
DIR_RIGHT = Vec2:new({1, 0, 1})
DIR_DOWN = Vec2:new({0, 1, 2})
DIR_LEFT = Vec2:new({-1, 0, 3})

-- GRID
local Grid = createClass()

function Grid:parseAndAppendRow(row)
    local start_position
    self.width_ = #row
    self.height_ = (self.height_ or 0) + 1
    local i = 1
    for space in row:gmatch("(.)") do
        if space == "^" then
            start_position = Vec2:new({i, self.height_})
        end

        table.insert(self, space == "#" and -1 or 0)
        i = i + 1
    end

    return start_position
end

function Grid:indexFor(vec) return (vec[2] - 1) * self.height_ + vec[1] end
function Grid:clearVisits()
    for i=1, #self do
        if self[i] > 0 then self[i] = 0 end
    end
end

function Grid:visitPositionWithDirection(pos, dir)
    local idx = self:indexFor(pos)
    self[idx] = self[idx] | 1 << dir[3]
end

function Grid:inLoop(pos, dir)
    local num = self[self:indexFor(pos)]
    return num > 0 and (num & (1 << dir[3])) > 0
end

function Grid:getVisited()
    local ret = {}
    for i=1, #self do
        if self[i] > 0 then
            local x = ((i-1)%self.width_)+1
            local y = ((i-1)//self.height_)+1
            table.insert(ret, Vec2:new({x, y}))
        end
    end

    return ret
end

function Grid:countVisited()
    return #(self:getVisited())
end

function Grid:outOfBounds(vec)
    return vec[2] <= 0 or vec[2] > self.height_ or
           vec[1] <= 0 or vec[1] > self.width_
end

function Grid:obstruct(pos) self[self:indexFor(pos)] = -1 end
function Grid:clear(pos) self[self:indexFor(pos)] = 0 end

function Grid:obstructionAt(vec)
    return self[self:indexFor(vec)] < 0
end

--DRIVER

local map = Grid:new()
local start_position

for line in io.lines() do
    if #line == 0 then break end
    start_position = map:parseAndAppendRow(line) or start_position
end

-- if looped, returns false
local function traverse(map)
    local position = start_position:clone()
    local direction = DIR_UP:clone()

    map:visitPositionWithDirection(position, direction)

    while true do
        position:add(direction)
        if map:outOfBounds(position) then return true end
        if map:inLoop(position, direction) then return false end

        if map:obstructionAt(position) then
            position:sub(direction)
            direction:rotateRight()
            goto continue
        end

        map:visitPositionWithDirection(position, direction)
        ::continue::
    end
end

local function part1()
    traverse(map)
    return map:countVisited()
end

local function part2()
    local loops = 0
    traverse(map)
    local visited = map:getVisited()
    map:clearVisits()

    for _, newObstruction in ipairs(visited) do
        if newObstruction:eq(start_position) then goto continue end

        map:obstruct(newObstruction)
        if not traverse(map) then
            loops = loops + 1
        end

        map:clear(newObstruction)
        map:clearVisits()

        ::continue::
    end

    return loops
end

--print(part1())
print(part2())
