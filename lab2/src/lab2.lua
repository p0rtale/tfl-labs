local notationMod = require("lab2.src.notation")
local syntaxTreeMod = require("lab2.src.syntaxTree")
local normalizationMod = require("lab2.src.normalization")

local operatorsTable = { syntaxTreeMod.Operator:new("|", 2, 1),
                         syntaxTreeMod.Operator:new("+", 2, 2),
                         syntaxTreeMod.Operator:new("*", 1, 3) }

local operators = syntaxTreeMod.Operators:new(operatorsTable)

local notationClass = notationMod.Notation:new(operators)

local regex = io.read()
local regexTree = syntaxTreeMod.Tree:new(notationClass:infixToPostfix(
                      notationClass:preprocessInfix(regex)), operators)

local rulesArr = {}
while true do
    local ruleStr = io.read()
    if ruleStr == nil then
        break
    end

    local i = ruleStr:find("=")
    local ruleLeftStr = ruleStr:sub(1, i - 2)
    local ruleRightStr = ruleStr:sub(i + 2, #ruleStr)

    local ruleLeftTree = syntaxTreeMod.Tree:new(notationClass:infixToPostfix(
                             notationClass:preprocessInfix(ruleLeftStr)), operators)
    local ruleRightTree = syntaxTreeMod.Tree:new(notationClass:infixToPostfix(
                              notationClass:preprocessInfix(ruleRightStr)), operators)
    local rule = normalizationMod.Rule:new(ruleLeftTree, ruleRightTree)

    rulesArr[#rulesArr+1] = rule
end
local rules = normalizationMod.Rules:new(rulesArr)

rules:normalize(regexTree)
print(notationClass:cleanInfix(notationClass:postfixToInfix(regexTree:toPostfixStr())))
