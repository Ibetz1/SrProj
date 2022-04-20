local function clamp(v, min, max)
    if v < min then return min end
    if v > max then return max end

    return v
end

local function HSV(h, s, v)
    v = v or 1; s = (1 - s) * (v or 0)

    local vert = math.ceil(h / 120)
    local rat = math.abs((h / 60) - 2 * vert)

    -- arc to vertex ratios along with extra channel
    local r, g = clamp(rat * v, s, 1), clamp((2 - rat) * v, s, 1)

    -- vertex shift
    if vert == 1 then return r, g, s end
    if vert == 2 then return s, r, g end
    return g, s, r
end

return HSV