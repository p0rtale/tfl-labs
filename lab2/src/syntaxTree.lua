local stackMod = require("lab2.src.stack")

local syntaxTreeMod = {}


syntaxTreeMod.Operand = {}

function syntaxTreeMod.Operand:new(name)
    local public = {}
    local private = {}

    public.name = name

    self.__index = self
    return setmetatable(public, self)
end


syntaxTreeMod.Operator = {}

function syntaxTreeMod.Operator:new(name, arity, priority)
    local public = {}
    local private = {}

    public.name = name
    public.arity = arity
    public.priority = priority

    function public:isUnary()
        return public.arity == 1
    end

    function public:isBinary()
        return public.arity == 2
    end

    self.__index = self
    return setmetatable(public, self)
end


syntaxTreeMod.Operators = {}

function syntaxTreeMod.Operators:new(operatorsTable)
    local public = {}
    local private = {}

    private.dict = {}
    for _, operator in pairs(operatorsTable) do
        private.dict[operator.name] = operator
    end

    function public:get(operatorName)
        return private.dict[operatorName]
    end

    function public:isExists(operatorName)
        return private.dict[operatorName] ~= nil
    end

    function public:append(operator)
        private.dict[operator.name] = operator
    end

    function public:remove(operatorName)
        private.dict[operatorName] = nil
    end

    self.__index = self
    return setmetatable(public, self)
end


syntaxTreeMod.Node = {}

function syntaxTreeMod.Node:new(data, childNum)
    local public = {}
    local private = {}

    local arr = {}
    for i = 1, childNum do
        arr[i] = {}
    end

    public.children = arr
    public.data = data

    function public:isOperand()
        return #public.children == 0
    end

    function public:isOperator()
        return not public.isOperand()
    end

    self.__index = self
    return setmetatable(public, self)
end


syntaxTreeMod.Tree = {}

function syntaxTreeMod.Tree:new(postfixStr, operators)
    local public = {}
    local private = {}

    public.operators = operators

    function private:getRegexSymbols(postfixStr)
        local dict = {}

        for i = 1, #postfixStr do
            local symbol = postfixStr:sub(i, i)
            if (string.byte("a") <= string.byte(symbol)) and
               (string.byte(symbol) <= string.byte("z")) then
                dict[symbol] = true
            end
        end

        return dict
    end

    function private:constructTree(postfixStr)
        local stack = stackMod.Stack:new()

        for i = 1, #postfixStr do
            local symbol = postfixStr:sub(i, i)
            if public.operators:isExists(symbol) then
                local operator = public.operators:get(symbol)
                local operatorNode = syntaxTreeMod.Node:new(operator, operator.arity)
                if operator:isUnary() then
                    operatorNode.children[1] = stack:pop()
                else
                    operatorNode.children[2] = stack:pop()
                    operatorNode.children[1] = stack:pop()
                end
                stack:push(operatorNode)
            else
                stack:push(syntaxTreeMod.Node:new(syntaxTreeMod.Operand:new(symbol), 0))
            end
        end

        return stack:peek()
    end

    public.root = nil
    if postfixStr ~= nil then
        public.symbols = private:getRegexSymbols(postfixStr)
        public.root = private:constructTree(postfixStr, operators) 
    end

    function private:dfs(node)
        if node:isOperand() then
            return node.data.name
        end -- node wraps operator
        if node.data:isUnary() then  
            return private:dfs(node.children[1])..node.data.name
        end
        if node.data:isBinary() then
            return private:dfs(node.children[1])..private:dfs(node.children[2])..node.data.name
        end
        error("undefined operator")
    end

    function public:toPostfixStr()
        if public.root == nil then
            return ""
        end
        return private:dfs(public.root)
    end


    self.__index = self
    return setmetatable(public, self)
end


return syntaxTreeMod
