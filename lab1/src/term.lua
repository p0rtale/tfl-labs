local utilsMod = require("src.utils")

local termMod = {}

termMod.Constructor = {}

function termMod.Constructor:new(name, argNum)
    local public = {}
    local private = {}

    public.name = name
    public.argNum = argNum

    function public:getName()
        return public.name
    end

    function public:getArgNum()
        return public.argNum
    end

    self.__index = self
    return setmetatable(public, self)
end

function termMod.parseConstructors(str)
    local constructors = {}
    local first, last = str:find("=")
    while true do
        first, last = str:find("%a%(%d+%)", last + 1)
        if first == nil then
            break
        end
        local name = str:sub(first, first)
        local arity = tonumber(str:sub(first + 2, last - 1))
        constructors[name] = termMod.Constructor:new(name, arity)
    end
    return constructors
end


termMod.Variable = {}

function termMod.Variable:new(name)
    local public = {}
    local private = {}

    public.name = name

    function public:getName()
        return public.name
    end

    function public:getArgNum()
        return nil
    end

    self.__index = self
    return setmetatable(public, self)
end

function termMod.parseVariables(str)
    local variables = {}
    local i = str:find("=")
    while true do
        i = str:find("%a", i + 1)
        if i == nil then
            break
        end
        local name = str:sub(i, i)
        variables[name] = termMod.Variable:new(name)
    end
    return variables
end


termMod.Node = {}

function termMod.Node:new(data, childsNum)
    local public = {}
    local private = {}

    local arr = {}
    for i = 1, childsNum do
        arr[i] = {}
    end

    public.childs = arr
    public.data = data

    function public:isVariable()
        return public.data.getArgNum() == nil
    end

    function public:isConstructor()
        return public.data.getArgNum() >= 0
    end

    function private:constructorToStr()
        local str = public.data:getName()

        str = str .. "("
        for i = 1, #public.childs do
            str = str..public.childs[i]:toStr()
            str = str .. ","
        end
        str = utilsMod.replaceChar(str, #str, ")")

        return str
    end

    function public:toStr()
        if public:isVariable() then
            return public.data:getName()
        end
        return private:constructorToStr()
    end

    self.__index = self
    return setmetatable(public, self)
end


function termMod.parseTermRec(str, variables, constructors)
    local term
    if #str == 1 then
        term = termMod.Node:new(variables[str:sub(1, 1)], 0)
    else
        local constructor = constructors[str:sub(1, 1)]
        local argNum = constructor:getArgNum()
        term = termMod.Node:new(constructor, argNum)
        local first = 3
        local last = first + 1
        for i = 1, argNum do
            local level = 0
            if str:sub(last, last) == "(" then
                level = 1
                last = last + 1
            end
            while level ~= 0 do
                local c = str:sub(last, last)
                if c == "(" then
                    level = level + 1
                elseif c == ")" then
                    level = level - 1
                end
                last = last + 1
            end
            term.childs[i] = termMod.parseTermRec(str:sub(first, last - 1), variables, constructors)
            if i < argNum then
                first = str:find("%a", last)
                last = first + 1
            end
        end
    end
    return term
end

function termMod.parseTerm(str, variables, constructors)
    local _, last = str:find(":%s*%a")
    return termMod.parseTermRec(str:sub(last, #str), variables, constructors)
end

return termMod
