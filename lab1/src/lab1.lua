local utilsMod = require("src.utils")
local termMod = require("src.term")
local multieqMod = require("src.multiEquation")
local mmunifMod = require("src.mmUnification")

local function input()
    local constrStr = io.read()
    local varsStr = io.read()
    local termPairStrs = {}
    while true do
        local firstTermStr = io.read()
        local secondTermStr = io.read()
        if secondTermStr == nil then
            break
        end
        termPairStrs[#termPairStrs+1] = { firstTermStr, secondTermStr }
    end
    return constrStr, varsStr, termPairStrs
end

local constrStr, varsStr, termPairStrs = input()

local constructors = termMod.parseConstructors(constrStr)
local variables = termMod.parseVariables(varsStr)

local system = multieqMod.MultiEquations:new()
local newVariables = {}
for i = 1, #termPairStrs do
    local newVarName = "x"..tostring(i)
    local newVar = termMod.Variable:new(newVarName)
    newVariables[newVarName] = newVar

    local firstTerm = termMod.parseTerm(termPairStrs[i][1], variables, constructors)
    local secondTerm = termMod.parseTerm(termPairStrs[i][2], variables, constructors)

    local multieq = multieqMod.MultiEquation:new({ termMod.Node:new(newVar, 0) }, { firstTerm, secondTerm })

    system:compactAppend(multieq)
end
for i = 1, #variables do
    local multieq = multieqMod.MultiEquation:new({ termMod.Node:new(variables[i], 0) }, {})
    system:compactAppend(multieq)
end

local status, res = pcall(mmunifMod.unify, system)
if not status then
    print("there is no unifier")
    os.exit(1)
end

for i = 1, #res:getArr() do
    local vars = res:getArr()[i]:getVariables()
    if not utilsMod.contains(newVariables, vars[1].data) then
        print(res:getArr()[i]:toStr())
    end
end
