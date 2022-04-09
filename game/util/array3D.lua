local array = {}
array.__index = array

function array:__call(w, h, d)
    local a = {}
    local d = d or 0

    self.w, self.h, self.d = w, h, d
    self.max_layer = 0

    for x = 1, w do
        a[x] = {}
        
        for y = 1, h do
            a[x][y] = {}

            for z = 1, d do
                a[x][y][z] = {}
            end
        end
    end

    return setmetatable(a, self)
end

-- gets value from array
function array:get(x, y, z, index)
    if x <= 0 or x > self.w or y <= 0 or y > self.h then return end

    if index then return self[x][y][z][index] end
    return self[x][y][z]
end

-- adds value to array
function array:add(data, x, y, z, index)
    if x <= 0 or x > self.w or y <= 0 or y > self.h then return end

    self[x][y][z][index] = data

    return index
end

-- removes value from array
function array:remove(x, y, z, index)
    if x <= 0 or x > self.w or y <= 0 or y > self.h then return end

    self[x][y][z][index] = nil
end

return setmetatable(array, array)