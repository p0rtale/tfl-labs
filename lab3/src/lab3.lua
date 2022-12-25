local parserMod = require("lab3.src.parser")
local commutativeImageMod = require("lab3.src.commutativeImage")

local cfgStr = io.read("*all")

-- local cfgStr = "[X]->[Y][X][X]\n[X]->a\n[Y]->[Y][Y][Y][X]a\n[Y]->[Y][X][X]a\n[Y]->b\n"

local cfg = parserMod.parseCFG(cfgStr)

local equations = commutativeImageMod.Equations:new(cfg:getEquations())
equations:toCommutativeImages()

local regexes = equations:getRegexes()
print("Commutative images of languages:")
print()
for i = 1, #regexes do
    local regex = regexes[i]
    print(regex.nterm.." = "..regex.image)
end
print()
print()

local ratios = equations:getLetterRatios()
print("Letter ratios:")
print()
for i = 1, #ratios do
    local ratio = ratios[i]
    print("Ratios for "..ratio.nterm..":")
    for term, termVectors in pairs(ratio.vectors) do
        local termVectorsStr = ""
        for i = 1, #termVectors do
            local termVector = termVectors[i]
            local termVectorStr = ""
            for j = 1, #termVector do
                termVectorStr = termVectorStr..termVector[j]..","
            end
            termVectorStr = termVectorStr:sub(1, #termVectorStr - 1)
            if #termVectorStr ~= 1 then
                termVectorStr = "("..termVectorStr..")"
            end
            termVectorsStr = termVectorsStr..termVectorStr.." | "
        end
        termVectorsStr = termVectorsStr:sub(1, #termVectorsStr - 3)
        print(term..": "..termVectorsStr)
    end
    print()
end
