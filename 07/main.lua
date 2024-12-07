#!/usr/bin/env lua

local problems = {}

for line in io.lines() do
    local result, parts = line:gmatch("(.+): (.+)")()
    local problem = { result = tonumber(result) }
    local numbers = {}
    for number in parts:gmatch("(%d+)") do
        table.insert(numbers, tonumber(number))
    end

    problem.numbers = numbers

    table.insert(problems, problem)
end

local function part1_recurse(result, numbers, current, idx)
    if idx > #numbers then return current == result end

    return part1_recurse(result, numbers, current + numbers[idx], idx+1) or
           part1_recurse(result, numbers, current * numbers[idx], idx+1)
end

local function part1(result, numbers)
    return part1_recurse(result, numbers, numbers[1], 2) and result or 0
end

local floor = math.floor
local log = math.log

--[[
you can implement the concat operation by multiplying the left-hand side by 10
enough times to right-pad it with the correct amount of least-significant zeroes
such that you can just add the right-hand side to "append" it.

e.g. 909 || 1 -> 909 * 10 = 9090 + 1 = 9091
     8 || 17 -> 8 * 100 = 800 + 17 = 817

You can find the correct power of 10 by taking the log10 of the right-hand side.

for perfect logs - i.e. log10 of 10 is exactly 1, but actually has two digits.
So we floor it (still 1) and then add 1, which is 2 (the correct number of
digits) and thus the correct power to exponentiate 10 by.

Yeah, you can just convert the numbers to strings and append them, but this made
it a second faster than that. And how often in your actual life do you get the
opportunity to apply _logarithms_?
--]]
local function part2_recurse(result, numbers, current, idx)
    if idx > #numbers then return current == result end

    return part2_recurse(result, numbers, current + numbers[idx], idx+1) or
           part2_recurse(result, numbers, current * numbers[idx], idx+1) or
           part2_recurse(result, numbers, current * (10 ^ (floor(log(numbers[idx], 10)) + 1)) + numbers[idx], idx+1)
end

local function part2(result, numbers)
    return part2_recurse(result, numbers, numbers[1], 2) and result or 0
end

local answer = 0

for _, problem in ipairs(problems) do
    --answer = answer + part1(problem.result, problem.numbers)
    answer = answer + part2(problem.result, problem.numbers)
end

print(answer)