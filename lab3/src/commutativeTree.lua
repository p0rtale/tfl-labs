local queueMod = require("lab2.src.queue")


local commutativeTreeMod = {}


local function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

local function appendValue(table, val)
    table[#table+1] = val
end


commutativeTreeMod.Operator = {}

function commutativeTreeMod.Operator:new(name)
    local public = {}
    local private = {}

    public.name = name

    self.__index = self
    return setmetatable(public, self)
end


commutativeTreeMod.Node = {}

local function copyNode(node)
    local copy = commutativeTreeMod.Node:new(node.operator)
    copy.terms = deepcopy(node.terms)
    for i = 1, #node.children do
        copy.children[i] = copyNode(node.children[i])
    end
    return copy
end

function commutativeTreeMod.Node:new(operator)
    local public = {}
    local private = {}

    public.terms = {}  -- for concatenation
    public.children = {}
    public.operator = operator

    function public:getOperatorName()
        return public.operator.name
    end

    self.__index = self
    return setmetatable(public, self)
end


commutativeTreeMod.Tree = {}

function commutativeTreeMod.Tree:new(nterm, cfgRuleRights)
    local public = {}
    local private = {}

    function private:constructTree(cfgRuleRights)
        local alterNode = commutativeTreeMod.Node:new(private.operators["|"])
        for i = 1, #cfgRuleRights do
            local ruleRight = cfgRuleRights[i]
            local concatNode = commutativeTreeMod.Node:new(private.operators["+"])
            for j = 1, #ruleRight do
                local element = ruleRight[j]
                local termNum = concatNode.terms[element.name]
                if termNum == nil then
                    concatNode.terms[element.name] = 1
                else
                    concatNode.terms[element.name] = termNum + 1
                end
            end
            appendValue(alterNode.children, concatNode)
        end

        return alterNode
    end

    private.operators = {
        ["|"] = commutativeTreeMod.Operator:new("|"),
        ["+"] = commutativeTreeMod.Operator:new("+"),
        ["*"] = commutativeTreeMod.Operator:new("*"),
    }

    public.nterm = nterm

    -- always alternative of concatenations (will not be reduced)
    public.root = private:constructTree(cfgRuleRights)

    function private:reduceAlterRule(node --[[ , parent, childIndex --]])
        -- example: (a|(b|c)) -> (a|b|c)
        if node:getOperatorName() == "|" then
            local alter = node
            for i = 1, #alter.children do
                local alterChild = alter.children[i]
                if alterChild:getOperatorName() == "|" then
                    for j = 1, #alterChild.children do
                        appendValue(alter.children, alterChild.children[j])
                    end
                    table.remove(alter.children, i)
                    return true
                end
            end
        end
        return false
    end

    function private:reduceConcatRule(node --[[ , parent, childIndex --]])
        -- example: (a+(b+c)) -> (a+b+c)
        if node:getOperatorName() == "+" then
            local concat = node
            for i = 1, #concat.children do
                local concatChild = concat.children[i]
                if concatChild:getOperatorName() == "+" then
                    for j = 1, #concatChild.children do
                        appendValue(concat.children, concatChild.children[j])
                    end
                    for term, count in pairs(concatChild.terms) do
                        if concat.terms[term] == nil then
                            concat.terms[term] = count
                        else
                            concat.terms[term] = concat.terms[term] + count
                        end
                    end
                    table.remove(concat.children, i)
                    return true
                end
            end
        end
        return false
    end

    function private:alterUnderIterRule(node, parent, childIndex)
        -- example: (a|b|c)* -> (a*+b*+c*)
        if node:getOperatorName() == "*" then
            local iter = node
            local iterChild = iter.children[1]
            if iterChild:getOperatorName() == "|" then
                local alter = iterChild
                parent.children[childIndex] = commutativeTreeMod.Node:new(private.operators["+"])
                local concat = parent.children[childIndex]
                for i = 1, #alter.children do
                    concat.children[i] = commutativeTreeMod.Node:new(private.operators["*"])
                    concat.children[i].children[1] = alter.children[i]
                end
                return true
            end
        end
        return false
    end

    function private:distributivityRule(node, parent, childIndex)
        -- example: (a+(b|c)) -> (a+b|a+c)
        if node:getOperatorName() == "+" then
            local concat = node
            for i = 1, #concat.children do
                local concatChild = concat.children[i]
                if concatChild:getOperatorName() == "|" then
                    local alterPrev = concatChild
                    local concatWithoutAlter = copyNode(concat)
                    table.remove(concatWithoutAlter.children, i)
                    parent.children[childIndex] = commutativeTreeMod.Node:new(private.operators["|"])
                    local alterNew = parent.children[childIndex]
                    for j = 1, #alterPrev.children do
                        alterNew.children[j] = commutativeTreeMod.Node:new(private.operators["+"])
                        local alterConcat = alterNew.children[j]
                        alterConcat.children[1] = copyNode(concatWithoutAlter)
                        alterConcat.children[2] = alterPrev.children[j]
                    end
                    return true
                end
            end
        end
        return false
    end

    function private:reduceIterHeightRule(node, parent, childIndex)
        -- example: (a*b)* -> (eps+a*b*b)
        if node:getOperatorName() == "*" then
            local iterChild = node.children[1]
            if iterChild:getOperatorName() == "+" then
                local concat = iterChild
                for i = 1, #concat.children do
                    local concatChild = concat.children[i]
                    if concatChild:getOperatorName() == "*" then
                        local iterUnderIter = concatChild
                        parent.children[childIndex] = commutativeTreeMod.Node:new(private.operators["|"])
                        local alterNew = parent.children[childIndex]
                        alterNew.children[1] = commutativeTreeMod.Node:new(private.operators["+"])
                        alterNew.children[2] = commutativeTreeMod.Node:new(private.operators["+"])
                        local iterNew = alterNew.children[2]
                        iterNew.children[1] = copyNode(iterUnderIter)

                        local constant = copyNode(concat)
                        table.remove(constant.children, i)

                        iterNew.children[2] = commutativeTreeMod.Node:new(private.operators["*"])
                        iterNew.children[2].children[1] = copyNode(constant)
                        iterNew.children[3] = copyNode(constant)

                        return true
                    end
                end
            end
        end
        return false
    end

    function private:reduceEpsIterRule(node --[[ , parent, childIndex --]])
        -- example: (eps)*abc -> abc
        if node:getOperatorName() == "+" then
            local concat = node
            for i = 1, #concat.children do
                local concatChild = concat.children[i]
                if concatChild:getOperatorName() == "*" then
                    local iter = concatChild.children[1]  -- under *
                    if iter:getOperatorName() == "+" then
                        local concatUnderIter = iter
                        if next(concatUnderIter.terms) == nil and #concatUnderIter.children == 0 then
                            table.remove(concat, i)
                            return true
                        end
                    end
                end
            end
        end
        return false
    end

    function private:applyRuleBFS(rule)
        local queue = queueMod.Queue:new()
        queue.push({ public.root, nil, nil })
        while #queue > 0 do
            local node, parent, childIndex = table.unpack(queue.pop())

            if rule(self, node, parent, childIndex) then
                return true
            end

            for i = 1, #node.children do
                queue.push({ node.children[i], node, i })
            end
        end
        return false
    end

    function public:normalize()
        local rules = {
            private.reduceAlterRule,
            private.reduceConcatRule,
            private.alterUnderIterRule,
            private.distributivityRule,
            private.reduceIterHeightRule,
            private.reduceEpsIterRule,
        }

        local isNormalized = false
        while not isNormalized do
            isNormalized = true
            for i = 1, #rules do
                if private:applyRuleBFS(rules[i]) then
                    -- print(i)
                    isNormalized = false
                    break
                end
            end
        end
    end

    function private:replaceNtermConcat(concat, nterm, substitution)
        if concat.terms[nterm] == nil then
            return false
        end
        for i = 1, concat.terms[nterm] do
            local substitutionCopy = copyNode(substitution)
            appendValue(concat.children, substitutionCopy)
        end
        concat.terms[nterm] = nil
        return true
    end

    function public:replaceNterm(nterm, substitution)
        local queue = queueMod.Queue:new()
        queue.push({ public.root })
        while #queue > 0 do
            local node = table.unpack(queue.pop())

            if node:getOperatorName() == "+" then
                private:replaceNtermConcat(node, nterm, substitution)
            end

            for i = 1, #node.children do
                queue.push({ node.children[i] })
            end
        end
    end

    function public:toArden()
        local constants = commutativeTreeMod.Node:new(private.operators["|"])
        local iterations = commutativeTreeMod.Node:new(private.operators["|"])
        while #public.root.children > 0 do
            local component = public.root.children[1] -- is concat
            table.remove(public.root.children, 1)

            if component.terms[public.nterm] then  -- nterm in constant part
                component.terms[public.nterm] = component.terms[public.nterm] - 1
                if component.terms[public.nterm] == 0 then
                    component.terms[public.nterm] = nil
                end
                appendValue(iterations.children, component)
            else
                local have = false  -- nterm in iter part
                for j = 1, #component.children do
                    local iteration = component.children[j].children[1]  -- under *
                    if iteration.terms[public.nterm] then
                        local newComponent = copyNode(component)
                        for term, count in pairs(iteration.terms) do
                            newComponent.terms[term] = newComponent.terms[term] + count
                        end
                        newComponent.terms[public.nterm] = newComponent.terms[public.nterm] - 1
                        appendValue(iterations.children, newComponent)
                        table.remove(component.children, j)
                        appendValue(public.root.children, component)
                        have = true
                        break
                    end
                end
                if not have then  -- no nterm in component
                    appendValue(constants.children, component)
                end
            end
        end

        for i = 1, #iterations.children do
            local iteration = iterations.children[i]
            private:replaceNtermConcat(iteration, public.nterm, constants)
            for j = 1, #iteration.children do
                private:replaceNtermConcat(iteration.children[j].children[1], public.nterm, constants)
            end
        end

        public.root = commutativeTreeMod.Node:new(private.operators["|"])
        public.root.children[1] = commutativeTreeMod.Node:new(private.operators["+"])
        local ardenConcat = public.root.children[1]
        ardenConcat.children[1] = commutativeTreeMod.Node:new(private.operators["*"])
        ardenConcat.children[1].children[1] = iterations
        ardenConcat.children[2] = constants
    end

    self.__index = self
    return setmetatable(public, self)
end

return commutativeTreeMod
