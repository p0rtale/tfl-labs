local stackMod = require("lab2.src.stack")
local syntaxTreeMod = require("lab2.src.syntaxTree")

local notationMod = {}

notationMod.Notation = {}

function notationMod.Notation:new(operators)
    local public = {}
    local private = {}

    private.operators = operators
    private.operators:append(syntaxTreeMod.Operator:new("(", 0, 0))

    function private:isSymbol(c)
        return c ~= "(" and c ~= ")" and not private.operators:isExists(c)
    end

    function public:preprocessInfix(infixStr)
        if infixStr == "" then
            return ""
        end

        local newStr = infixStr:sub(1, 1)
        local symbolPrev = infixStr:sub(1, 1)
        for i = 2, #infixStr do
            local symbolCur = infixStr:sub(i, i)

            if (symbolPrev == "*" or symbolPrev == ")" or private:isSymbol(symbolPrev)) and
               (symbolCur == "(" or private:isSymbol(symbolCur)) then
                newStr = newStr .. "+" .. symbolCur
            elseif (symbolPrev == "(" and symbolCur == "|" or
                     symbolPrev == "|" and symbolCur == ")" or
                     symbolPrev == "(" and symbolCur == ")") then
                newStr = newStr .. "." .. symbolCur            
            else
                newStr = newStr .. symbolCur
            end

            symbolPrev = symbolCur
        end
        return newStr
    end

    function public:cleanInfix(infixStr)
        local newStr = ""
        for i = 1, #infixStr do
            local symbol = infixStr:sub(i, i)
            if symbol ~= "+" and symbol ~= "." then
                newStr = newStr .. symbol
            end
        end
        return newStr
    end

    function public:infixToPostfix(infixStr)
        local postfixStr = ""
        local stack = stackMod.Stack:new()

        for i = 1, #infixStr do
            local symbol = infixStr:sub(i, i)

            if symbol == "(" then
                stack:push(symbol)
            elseif symbol == ")" then
                while stack:getSize() > 0 and stack:peek() ~= "(" do
                    postfixStr = postfixStr..stack:pop()
                end 
                stack:pop()
            elseif private.operators:isExists(symbol) then
                local op = symbol                
                while (stack:getSize() > 0 and
                       (private.operators:get(stack:peek()).priority >= private.operators:get(op).priority)) do
                    postfixStr = postfixStr..stack:pop()
                end
                stack:push(op);
            else
                postfixStr = postfixStr..symbol
            end
        end

        while stack:getSize() > 0 do
            postfixStr = postfixStr..stack:pop()
        end

        return postfixStr
    end

    function public:postfixToInfix(postfixStr)
        local stack = stackMod.Stack:new()

        for i = 1, #postfixStr do
            local symbol = postfixStr:sub(i, i)
            if private.operators:isExists(symbol) then
                local op = symbol
                if private.operators:get(op):isUnary() then
                    stack:push(stack:pop()..op)
                else
                    local operandSecond, operandFirst = stack:pop(2)
                    stack:push("("..operandFirst..op..operandSecond..")") 
                end
            else
                stack:push(symbol)
            end
        end

        return stack:peek()
    end

    self.__index = self
    return setmetatable(public, self)
end

return notationMod
