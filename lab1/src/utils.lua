local utilsMod = {}

function utilsMod.replaceChar(str, pos, char)
    return str:sub(1, pos-1) .. char .. str:sub(pos+1)
end

function utilsMod.contains(table, val)
    for _, v in pairs(table) do
        if v == val then
           return true
        end
     end
     return false
end

function utilsMod.containsData(table, val)
    for _, v in pairs(table) do
        if v.data == val.data then
           return true
        end
     end
     return false
end

function utilsMod.appendValue(table, val)
    table[#table+1] = val
end

function utilsMod.appendValues(table, vals)
    for i = 1, #vals do
        utilsMod.appendValue(table, vals[i])
    end
end

return utilsMod
