local cfgMod = require("lab3.src.cfg")

local parserMod = {}

function parserMod.parseCFG(str)
    local arrowPattern = "^->"
    local termPattern = "^[%a%d]"
    local ntermPattern = "^%[%a+%d*%]"

    str = string.gsub(str, "[^%S\n]+", "")
    if #str == 0 then
        error("parseCFG: At least one rule is needed")
    end

    local rules = {}
    local ruleNumber = 1
    while #str ~= 0 do
        local i, j
        i, j = string.find(str, ntermPattern)
        if i == nil then
            error("parseCFG: No nterm found".." (Rule number - "..tostring(ruleNumber)..")")
        end
        local ntermName = str:sub(i, j)
        local left = cfgMod.Nterm:new(ntermName)
        str = str:sub(j + 1)

        i, j = string.find(str, arrowPattern)
        if i == nil then
            error("parseCFG: No arrow found".." (Rule number - "..tostring(ruleNumber)..")")
        end
        str = str:sub(j + 1)

        local right = {}
        while i ~= nil do
            i, j = string.find(str, termPattern)
            if i ~= nil then
                local termName = str:sub(i, j)
                local term = cfgMod.Term:new(termName)
                right[#right + 1] = term
            else
                i, j = string.find(str, ntermPattern)
                if i ~= nil then
                    local ntermName = str:sub(i, j)
                    local nterm = cfgMod.Nterm:new(ntermName)
                    right[#right + 1] = nterm
                end
            end
            if j ~= nil then
                str = str:sub(j + 1)
            end
        end

        if str:sub(1, 1) ~= "\n" then
            error("parseCFG: Couldn't parse the rule".." (Rule number - "..tostring(ruleNumber)..")")
        end
        str = str:sub(2)

        rules[#rules + 1] = cfgMod.Rule:new(left, right)

        ruleNumber = ruleNumber + 1
    end

    return cfgMod.CFG:new(rules)
end

return parserMod
