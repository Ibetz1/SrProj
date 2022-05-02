return function(val, min, max)
    if val > max then return min end
    if val < min then return max end

    return val
end