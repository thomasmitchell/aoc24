#!/usr/bin/env lua

local function report_is_safe(report)
    if #report == 0 or #report == 1 then
        return #report >= 1
    end

    local comp = report[1] < report[2] and -1 or 1

    for i=2, #report do
        local abs_diff = (report[i-1] - report[i]) * comp
        if not (abs_diff > 0 and abs_diff <= 3) then
            return false
        end
    end

    return true
end

local function report_is_damp_safe(report, skip)
    if #report == 0 or #report == 1 or (#report == 2 and skip) then
        return #report >= 1
    end

    local comp = report[1] < report[2] and -1 or 1
    if     skip == 1 then
        comp = report[2] < report[3] and -1 or 1
    elseif skip == 2 then
        comp = report[1] < report[3] and -1 or 1
    end

    for i=2, #report do
        local idx1, idx2 = i-1, i
        if     idx1 == skip then idx1 = idx1-1
        elseif idx2 == skip then idx2 = idx2+1
        end

        if idx1 == 0 or idx2 > #report then goto continue end

        local abs_diff = (report[idx1] - report[idx2]) * comp
        if not (abs_diff > 0 and abs_diff <= 3) then
            if skip then return false end
            return report_is_damp_safe(report, idx1) or
                   report_is_damp_safe(report, idx2) or
                   (idx1 == 2 and report_is_damp_safe(report, 1)) --special case asc/desc issue at first to second interval
        end

        ::continue::
    end

    return true
end

local function calc_safe_reports(reports)
    local num_safe = 0
    for _, report in ipairs(reports) do
        num_safe = num_safe + (report_is_safe(report) and 1 or 0)
    end

    return num_safe
end

local function calc_damp_safe_reports(reports)
    local num_safe = 0
    for _, report in ipairs(reports) do
        num_safe = num_safe + (report_is_damp_safe(report) and 1 or 0)
    end

    return num_safe
end

local reports = {}

for line in io.lines() do
    local report = {}
    for num in string.gmatch(line, "([^%s]+)") do
        table.insert(report, tonumber(num))
    end

    table.insert(reports, report)
end

--print(calc_safe_reports(reports))
print(calc_damp_safe_reports(reports))
