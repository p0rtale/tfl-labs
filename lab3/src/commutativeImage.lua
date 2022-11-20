local commutativeImageMod = {}


local function appendValue(table, val)
    table[#table+1] = val
end


commutativeImageMod.Equations = {}

function commutativeImageMod.Equations:new(equations)
    local public = {}
    local private = {}

    public.equations = equations

    function private:zeros(num)
        local vector = {}
        for i = 1, num do
            vector[i] = 0
        end
        return vector
    end

    function private:getEquationLetterRatios(equation)
        local ratioVectors = {}
        local alter = equation.root
        for i = 1, #alter.children do
            local alterConcat = alter.children[i]
            local concatRatioVector = {}
            for term, count in pairs(alterConcat.terms) do
                concatRatioVector[term] = private:zeros(#alterConcat.children + 1)  -- plus constant
                concatRatioVector[term][1] = count
            end
            for j = 1, #alterConcat.children do
                local concatIter = alterConcat.children[j].children[1]  -- under *
                for term, count in pairs(concatIter.terms) do
                    if concatRatioVector[term] == nil then
                        concatRatioVector[term] = private:zeros(#alterConcat.children + 1)  -- plus constant
                    end
                    concatRatioVector[term][j + 1] = concatRatioVector[term][j + 1] + count
                end
            end
            for term, vector in pairs(concatRatioVector) do
                if ratioVectors[term] == nil then
                    ratioVectors[term] = {}
                end
                appendValue(ratioVectors[term], vector)
            end
        end
        return ratioVectors
    end

    function public:getLetterRatios()
        local ratios = {}
        for i = 1, #public.equations do
            local ratio = {}
            local equation = public.equations[i]
            ratio.nterm = equation.nterm
            ratio.vectors = private:getEquationLetterRatios(equation)
            appendValue(ratios, ratio)
        end
        return ratios
    end

    function private:getEquationRegex(equation)
        local regex = ""
        local alter = equation.root
        for i = 1, #alter.children do
            local alterConcat = alter.children[i]
            local concatRegex = ""
            for j = 1, #alterConcat.children do
                local concatIter = alterConcat.children[j].children[1]  -- under *
                local iterRegex = ""
                for term, count in pairs(concatIter.terms) do
                    for _ = 1, count do
                        iterRegex = iterRegex..term
                    end
                end
                concatRegex = concatRegex.."("..iterRegex..")*"
            end
            local concatConstantRegex = ""
            for term, count in pairs(alterConcat.terms) do
                for _ = 1, count do
                    concatConstantRegex = concatConstantRegex..term
                end
            end
            concatRegex = concatRegex..concatConstantRegex
            regex = regex..concatRegex.."|"
        end
        regex = regex:sub(1, #regex - 1)
        return regex
    end

    function public:getRegexes()
        local regexes = {}
        for i = 1, #public.equations do
            local regex = {}
            local equation = public.equations[i]
            regex.nterm = equation.nterm
            regex.image = private:getEquationRegex(equation)
            appendValue(regexes, regex)
        end
        return regexes
    end

    function public:toCommutativeImages()
        for i = 1, #public.equations do
            local equation = public.equations[i]
            equation:normalize()
            equation:toArden()
            -- equation:normalize()
            for j = 1, #public.equations do
                if j ~= i then
                    public.equations[j]:replaceNterm(equation.nterm, equation.root)
                    -- public.equations[j]:normalize()
                end
            end
        end
        for i = 1, #public.equations do
            local equation = public.equations[i]
            equation:normalize()
        end
    end

    self.__index = self
    return setmetatable(public, self)
end


return commutativeImageMod
