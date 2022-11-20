local syntaxTreeMod = require("lab2.src.syntaxTree")
local queueMod = require("lab2.src.queue")


local normalizationMod = {}


normalizationMod.Rule = {}

function normalizationMod.Rule:new(leftPart, rightPart)
    local public = {}
    local private = {}

    public.left = leftPart
    public.right = rightPart

    self.__index = self
    return setmetatable(public, self)
end


normalizationMod.Rules = {}

function normalizationMod.Rules:new(rules)
    local public = {}
    local private = {}

    public.rules = rules

    function private:matchConcatEps(regexRoot, ruleRoot, symbols, vars)
        local regexOperandName = regexRoot.data.name
        local ruleOperatorName = ruleRoot.data.name
        if ruleOperatorName ~= "+" then
            return false
        end

        local ruleChildLeft = ruleRoot.childs[1]
        local ruleChildRight = ruleRoot.childs[2]
        if ruleChildLeft:isOperator() or ruleChildRight:isOperator() then
            return false
        end

        -- ruleChildLeft and ruleChildRight are operands
        local ruleChildLeftName = ruleChildLeft.data.name
        local ruleChildRightName = ruleChildRight.data.name

        if ruleChildRightName == regexOperandName then
            local temp = ruleChildRightName
            ruleChildRightName = ruleChildLeftName
            ruleChildLeftName = temp
        end

        if ruleChildLeftName == regexOperandName then
            if symbols[ruleChildRightName] == nil then
                if vars[ruleChildRightName] ~= nil then
                    if vars[ruleChildRightName].data.name == "." then
                        return true
                    end
                    return false
                end
                vars[ruleChildRightName] = syntaxTreeMod.Node:new(syntaxTreeMod.Operand:new("."), 0)
                return true
            end
            return false
        end

        return false
    end

    function private:match(regexRoot, ruleRoot, symbols, vars)
        if ruleRoot:isOperand() then
            local ruleOperandName = ruleRoot.data.name
            if symbols[ruleOperandName] == nil then
                if vars[ruleOperandName] ~= nil then
                    return private:match(regexRoot, vars[ruleOperandName], symbols, vars)
                end
                vars[ruleOperandName] = regexRoot
                return true
            end
            if regexRoot:isOperator() then
                return false
            end
            local regexOperandName = regexRoot.data.name
            if regexOperandName == ruleOperandName then
                return true
            end
            return false
        end
        if regexRoot:isOperator() then
            local ruleOperatorName = ruleRoot.data.name
            local regexOperatorName = regexRoot.data.name
            if ruleOperatorName == regexOperatorName then
                for i = 1, #regexRoot.childs do
                    if not private:match(regexRoot.childs[i], ruleRoot.childs[i], symbols, vars) then
                        return false
                    end
                end
                return true
            end
        end

        -- regexRoot is operand and ruleRoot is operator
        if private:matchConcatEps(regexRoot, ruleRoot, symbols, vars) then
            return true
        end

        return false
    end

    function private:dfsBuild(ruleRoot, vars)
        if ruleRoot:isOperand() then
            local operandName = ruleRoot.data.name
            local varRoot = vars[operandName]
            if varRoot ~= nil then
                return varRoot
            end
            return syntaxTreeMod.Node:new(syntaxTreeMod.Operand:new(operandName), 0)
        end
        local newRoot = syntaxTreeMod.Node:new(ruleRoot.data, #ruleRoot.childs)
        if ruleRoot.data:isUnary() then
            newRoot.childs[1] = private:dfsBuild(ruleRoot.childs[1], vars)
            return newRoot
        end
        if ruleRoot.data:isBinary() then
            newRoot.childs[1] = private:dfsBuild(ruleRoot.childs[1], vars)
            newRoot.childs[2] = private:dfsBuild(ruleRoot.childs[2], vars)
            return newRoot
        end
    end

    function private:rebuildSubTree(ruleRoot, vars)
        local newTree = syntaxTreeMod.Tree:new()
        newTree.root = private:dfsBuild(ruleRoot, vars)
        return newTree
    end

    function private:applyRuleToSubTree(regexRoot, rule, symbols)
        local vars = {}
        if not private:match(regexRoot, rule.left.root, symbols, vars) then
            return nil
        end
        return private:rebuildSubTree(rule.right.root, vars)
    end

    function private:bfs(regexTree, rule)
        local queue = queueMod.Queue:new()
        queue.push({ regexTree.root, nil, nil })
        while #queue > 0 do
            local node, parent, idx = table.unpack(queue.pop())

            local newSubTree = private:applyRuleToSubTree(node, rule, regexTree.symbols)
            if newSubTree ~= nil then
                if parent == nil then
                    regexTree.root = newSubTree.root
                else
                    parent.childs[idx] = newSubTree.root
                end
                return true
            end

            for i = 1, #node.childs do
                queue.push({ node.childs[i], node, i })
            end
        end
        return false
    end

    function public:normalize(regexTree)
        local isNormalized = false
        while not isNormalized do
            isNormalized = true
            for i = 1, #public.rules do
                if private:bfs(regexTree, public.rules[i]) then
                    -- print(i)
                    isNormalized = false
                    break
                end
            end
        end
    end

    self.__index = self
    return setmetatable(public, self)
end


return normalizationMod
