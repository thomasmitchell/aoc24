#!/usr/bin/env lua

local function is_right_order(update, dependencies)
    --with the assumption that no page can appear twice
    --we can think about the problem statement instead as:
    -- if a page in the list has a given dependency, it is wrong for that
    -- dependency to appear after that page.

    --mark down dependencies of pages we've already seen in this map
    local forbidden = {}
    for _, page in ipairs(update) do
        --if we've seen something for which this is a dependency already, then
        --this is misordered
        if forbidden[page] then return false end

        --mark the deps as verboten
        for _, dep in ipairs(dependencies[page] or {}) do
            forbidden[dep] = true
        end
    end

    --if we're here, we've checked every page and there are no violations.
    return true
end

local function reorder_update_helper(page, dependencies, found, acc)
    --this return skips both non-present dependencies and dependencies that
    --are already in the output
    if not found[page] then return end

    for _, dep in ipairs(dependencies[page] or {}) do
        --recurse until we get to the start of the dependency chain
        reorder_update_helper(dep, dependencies, found, acc)
    end

    --if we're here, we're at the current front of the remaining dependency chain
    table.insert(acc, page)
    --mark that we've output this so that we don't put it in the output twice
    -- if its also the dependency of another required page
    found[page] = false
end

local function reorder_update(update, dependencies)
    --make a map showing the presence of each page found in the update.
    --as we add the page in its correct position to the output list, we'll
    --mark it as false in this map.
    local found = {}
    for _, page in ipairs(update) do
        found[page] = true
    end

    local ret = {} --accumulator in recursive helper. acts as return value of recursion

    --for each page in the current update, insert it with its dependencies before it...
    --recursing for those dependencies so that their dependencies are before _it_ etc.
    -- the helper removes things it updates from the `found` map, so we won't
    -- accidentally insert the same thing twice
    for _, page in ipairs(update) do
        reorder_update_helper(page, dependencies, found, ret)
    end

    return ret
end

local function part_one_should_sum(update, dependencies)
    return is_right_order(update, dependencies) and update or nil
end

local function part_two_should_sum(update, dependencies)
    --only count misordered updates
    if is_right_order(update, dependencies) then return nil end
    --if we're here, this update is misordered. order it properly and return it.
    return reorder_update(update, dependencies)
end

--get the dependency list and build a DAG using a dictionary.
-- by "dependency, I mean that given a page key in this map, each page in the
-- value list cannot appear _after_ it (if its present, it must be _before_ it).
local dependencies = {}

while true do
    local line = io.read("*line")
    if #line == 0 then break end

    local dep, page = line:gmatch("(%d+)|(%d+)")()
    dependencies[page] = dependencies[page] or {}
    table.insert(dependencies[page], dep)
end

--process each "update", summing as we go
local sum = 0

while true do
    local line = io.read("*line")
    if not line or #line == 0 then break end

    local update = {}
    --split on commas
    for page in line:gmatch("([^,]+)") do
        table.insert(update, page)
    end

    --[[
        the "part" function will output (the pointer) to whatever map we
        need to sum the center value of. If we shouldn't sum it, it returns nil.
    --]]
    --local new_update = part_one_should_sum(update, dependencies)
    local new_update = part_two_should_sum(update, dependencies)

    if new_update then
        --floats are defacto number type in lua, so tell it to integer divide with //.
        sum = sum + tonumber(new_update[(#new_update//2) + 1])
    end
end

print(sum)