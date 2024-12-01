#!/usr/bin/env lua

function calc_diff(list1, list2)
    table.sort(list1)
    table.sort(list2)

    local diff = 0

    for idx, _ in ipairs(list1) do
        diff = diff + math.abs(list1[idx] - list2[idx])
    end

    return diff
end

function calc_similarity(list1, list2)
    local right_list_occurrences = {}
    for _, num in ipairs(list2) do
        right_list_occurrences[num] = (right_list_occurrences[num] or 0) + 1
    end

    local similarity = 0
    for _, num in ipairs(list1) do
        similarity = similarity + (right_list_occurrences[num] or 0) * num
    end

    return similarity
end



local list1, list2 = {}, {}

while true do
    local n1, n2 = io.read("*number", "*number")
    if not n1 then break end

    table.insert(list1, n1)
    table.insert(list2, n2)
end

--print(calc_diff(list1, list2))
print(calc_similarity(list1, list2))
