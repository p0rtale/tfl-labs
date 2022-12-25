local commutativeTreeMod = require("lab3.src.commutativeTree")

local cfgMod = {}

local function appendValue(table, val)
    table[#table+1] = val
end


cfgMod.Nterm = {}

function cfgMod.Nterm:new(name)
    local public = {}
    local private = {}

    public.name = name

    function public:isTerm()
        return false
    end

    function public:isNterm()
        return true
    end

    self.__index = self
    return setmetatable(public, self)
end


cfgMod.Term = {}

function cfgMod.Term:new(name)
    local public = {}
    local private = {}

    public.name = name

    function public:isTerm()
        return true
    end

    function public:isNterm()
        return false
    end

    self.__index = self
    return setmetatable(public, self)
end


cfgMod.Rule = {}

function cfgMod.Rule:new(left, right)
    local public = {}
    local private = {}

    public.left = left
    public.right = right

    self.__index = self
    return setmetatable(public, self)
end


cfgMod.CFG = {}

function cfgMod.CFG:new(rules)
    local public = {}
    local private = {}

    public.rules = {}  -- map of lists (ntermName -> list<right part of the rule>)
    public.terms = {}
    public.nterms = {}
    for i = 1, #rules do
        local rule = rules[i]
        local ruleNtermName = rule.left.name
        if not public.nterms[ruleNtermName] then
            public.nterms[ruleNtermName] = true
            public.rules[ruleNtermName] = {}
        end
        for j = 1, #rule.right do
            local element = rule.right[j]
            if element:isTerm() then
                public.terms[element.name] = true
            end
            if element:isNterm() then
                -- ...
            end
        end
        appendValue(public.rules[ruleNtermName], rule.right)
    end

    function public:deleteChainRules()
        -- ...
    end

    function public:deleteEpsilonRules()
        -- ...
    end

    function public:getEquations()
        local ntermsSorted = {}
        for ntermName, _ in pairs(public.nterms) do
            appendValue(ntermsSorted, ntermName)
        end
        table.sort(ntermsSorted)

        local equations = {}
        for i = 1, #ntermsSorted do
            local left = ntermsSorted[i]
            local rights = public.rules[ntermsSorted[i]]
            local equation = commutativeTreeMod.Tree:new(left, rights)
            appendValue(equations, equation)
        end
        return equations
    end

    self.__index = self
    return setmetatable(public, self)
end

return cfgMod
