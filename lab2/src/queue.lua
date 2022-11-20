local queueMod = {}

queueMod.Queue = {}

function queueMod.Queue:new()
    local out = {}
    local first, last = 0, -1

    out.push = function(item)
        last = last + 1
        out[last] = item
    end

    out.pop = function()
        if first <= last then
            local value = out[first]
            out[first] = nil
            first = first + 1
            return value
        end
    end

    out.iterator = function()
        return function()
            return out.pop()
        end
    end

    setmetatable(out, {
        __len = function()
            return (last-first+1)
        end,
    })

    return out
end

return queueMod
