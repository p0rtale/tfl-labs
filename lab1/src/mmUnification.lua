local utilsMod = require("lab1.src.utils")
local multieqMod = require("lab1.src.multiEquation")

local mmunifMod = {}

local function varsInTerm(term, vars)
    if term:isVariable() then
        if utilsMod.containsData(vars, term) then
            return true
        else
            return false
        end
    else
        for i = 1, #term.children do
            if varsInTerm(term.children[i], vars) then
                return true
            end
        end
        return false
    end
end

local function varsInSystem(system, vars)
    for i = 1, #system:getArr() do
        local terms = system:getArr()[i]:getTerms()
        for j = 1, #terms do
            if varsInTerm(terms[j], vars) then
                return true
            end
        end
    end
    return false
end

local function findUniqueMultiEquation(system)
    for i = 1, #system:getArr() do
        local vars = system:getArr()[i]:getVariables()
        local flag = varsInSystem(system, vars)
        if not flag then
            return i
        end
    end
    error("fail: vars in system")
end

function mmunifMod.unify(system)
    local resultSystem = multieqMod.MultiEquations:new()

    while #system:getArr() ~= 0 do
        local pos = findUniqueMultiEquation(system)
        local multieq = system:getArr()[pos]
        table.remove(system:getArr(), pos)

        local commonPart, border = multieq:getCommonPart()
        if commonPart then
            resultSystem:compactAppend(multieqMod.MultiEquation:new(multieq:getVariables(), { commonPart }))
        end

        if border then
            for i = 1, #border:getArr() do
                system:compactAppend(border:getArr()[i])
            end
        end
    end

    return resultSystem
end

return mmunifMod
