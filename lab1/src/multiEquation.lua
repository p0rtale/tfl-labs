local utilsMod = require("lab1.src.utils")
local termMod = require("lab1.src.term")

local multieqMod = {}

multieqMod.MultiEquations = {}

function multieqMod.MultiEquations:new()
    local public = {}
    local private = {}

    private.arr = {}

    function public:getArr()
        return private.arr
    end

    function public:compactAppend(multiEq)
        local var = multiEq.getVariables()[1]
        for i = 1, #private.arr do
            local curMultiEq = private.arr[i]
            local curVars = curMultiEq.getVariables()
            local curTerms = curMultiEq.getTerms()
            if utilsMod.containsData(curVars, var) then
                utilsMod.appendValues(curTerms, multiEq.getTerms())
                return
            end
        end
        utilsMod.appendValue(private.arr, multiEq)
    end

    self.__index = self
    return setmetatable(public, self)
end


multieqMod.MultiEquation = {}

function multieqMod.MultiEquation:new(variables, terms)
    local public = {}
    local private = {}

    private.variables = variables
    private.terms = terms

    function public.getVariables()
        return private.variables
    end

    function public.getTerms()
        return private.terms
    end

    function private:getLevelVariable(nodes)
        local variable = nil
        local constructor = nil

        for i = 1, #nodes do
            if nodes[i]:isVariable() then
                variable = nodes[i].data
            elseif nodes[i]:isConstructor() then
                if constructor ~= nil and constructor ~= nodes[i].data then
                    error("different constructors")
                end
                constructor = nodes[i].data
            end
        end

        return variable
    end

    function private:getCommonPartRec(border, roots)
        local commonNode
        local variable = private:getLevelVariable(roots)
        if variable ~= nil then
            commonNode = termMod.Node:new(variable, 0)

            local terms = {}
            for i = 1, #roots do
                if roots[i].data ~= variable then
                    utilsMod.appendValue(terms, roots[i])
                end
            end
            local multieq = multieqMod.MultiEquation:new({ termMod.Node:new(variable, 0) }, terms)
            border:compactAppend(multieq)

            return commonNode
        end

        local root = roots[1]
        local constructor = root.data
        commonNode = termMod.Node:new(constructor, constructor:getArgNum())

        for i = 1, #root.children do
            local childRoots = {}
            for j = 1, #roots do
                childRoots[j] = roots[j].children[i]
            end
            commonNode.children[i] = private:getCommonPartRec(border, childRoots)
        end

        return commonNode
    end

    function public:getCommonPart()
        if #private.terms == 0 then
            return nil, nil
        end
        if #private.terms == 1 then
            return private.terms[1], nil
        end

        local roots = {}
        for i = 1, #private.terms do
            roots[i] = private.terms[i]
        end

        local border = multieqMod.MultiEquations:new()
        local commonPart = private:getCommonPartRec(border, roots)

        return commonPart, border
    end

    function public:toStr()
        local str = "{"
        local vars = public:getVariables()
        for i = 1, #vars do
            str = str .. vars[i]:toStr() .. ","
        end
        str = utilsMod.replaceChar(str, #str, "}")
        str = str .. " = ("
        local terms = public:getTerms()
        for i = 1, #terms do
            str = str .. terms[i]:toStr() .. ","
        end
        str = utilsMod.replaceChar(str, #str, ")")
        return str
    end

    self.__index = self
    return setmetatable(public, self)
end

return multieqMod
