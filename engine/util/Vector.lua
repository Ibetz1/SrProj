local ceil = math.ceil
local floor = math.floor
local sqrt = math.sqrt
local cos = math.cos
local sin = math.sin
local atan = math.atan
local tan = math.tan

local vec2 = {
    -- custom type
    __type = 'vector2',

    -- custom print function
    __tostring = function(vec) 
        return 'vec2(' .. vec.x .. ', ' .. vec.y .. ')'
    end,

    -- inverse functionality
    __unm = function(a)
        a.x, a.y = -a.x, -a.y

        return a
    end,

    -- equalality funtionality
    __eq = function(a, b)
        return (a.x == b.x and a.y == b.y)
    end,

    -- addition functionality
    __add = function(a, b)

        -- check for number values
        if type(a) == 'number' then
            b.x, b.y = b.x + a, b.y + a

            return b
        end

        if type(b) == 'number' then
            a.x, a.y = a.x + b, a.y + b

            return a
        end

        -- apply values
        a.x, a.y = a.x + b.x, a.y + b.y

        return a
    end,

    -- subtraction functionality
    __sub = function(a, b)

        -- check for number values
        if type(a) == 'number' then
            -- subtract values
            b.x, b.y = b.x - a, b.y - a

            return b
        end

        if type(b) == 'number' then
            -- subtract values
            a.x, a.y = a.x - b, a.y - b

            return a
        end

        -- apply values
        a.x, a.y = a.x - b.x, a.y - b.y

        return a
    end,

    -- subtraction functionality
    __mul = function(a, b)

        -- check for number values
        if type(a) == 'number' then
            -- multiply values
            b.x, b.y = b.x * a, b.y * a

            return b 
        end

        if type(b) == 'number' then
            -- multiply values
            a.x, a.y = a.x * b, a.y * b

            return a
        end

        -- apply values
        a.x, a.y = a.x * b.x, a.y * b.y

        return a
    end,

    -- subtraction functionality
    __div = function(a, b)

        -- check for number values
        if type(a) == 'number' then
            -- divide values
            b.x, b.y = b.x / a, b.y / a

            return b 
        end

        if type(b) == 'number' then
            -- divide values
            a.x, a.y = a.x / b, a.y / b

            return a
        end

        -- apply values
        a.x, a.y = a.x / b.x, a.y / b.y

        return a
    end
}

function vec2:zero()
    self.x, self.y = 0, 0
end

-- clone vector
function vec2:clone()
    return vec2(self.x, self.y)
end

-- get vector magnitude squared
function vec2:lengthSq()
    return self.x ^ 2 + self.y ^ 2
end

-- get vector magnitude
function vec2:length()
    return sqrt(self.x ^ 2 + self.y ^ 2)
end

-- set vector magnitude
function vec2:setLength(len)
    self:unit()

    self = self * len

    return self
end

-- get distance between vectors
function vec2:dist(b)
    return math.sqrt(math.pow(b.x - self.x, 2) + math.pow(b.y-self.y, 2))
end

-- get normalized vector
function vec2:unit()
    local m = self:length()

    -- make sure vector is not 0
    if m ~= 0 then
        self = self / m
    end

    return self
end

-- get angle of vector
function vec2:angle()
    return atan(self.y / self.x)
end

-- get vector from angle
function vec2:convertAngle(a, dist)
    self.x = cos(a) * dist
    self.y = sin(a) * dist
end

-- clamp vector x and y axis
function vec2:clamp(min, max)
    self.x = math.min(math.max(self.x, min), max)
    self.y = math.min(math.max(self.x, min), max)
end

-- rotate vector (clockwise)
function vec2:rotate(angle)
    local dx = cos(-angle)
    local dy = sin(-angle)

    return vec2(dx*self.x - dy*self.y, dy*self.x + dx*self.y)
end

-- custom unpack functionality
function vec2:unpack(a)
    return a.x, a.y
end

-- creates a new vector
function vec2:__call(x, y)
    return setmetatable({x = x or 0, y = y or 0}, vec2)
end

-- meta data
vec2.__index = vec2

setmetatable(vec2, vec2)

return vec2