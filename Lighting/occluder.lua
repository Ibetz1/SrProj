local occluder = Object:new()

function occluder:init(x, y, w, h, settings)
    local w, h = w or 0, h or 0

    self.position = Vector(x, y)
    self.w, self.h = w, h

    -- optional
    self.texture = nil
    self.normal = nil
    self.glow = nil

    for name, val in pairs(settings or {}) do
        self[name] = val
    end

    self:sizeMatrix(w, h)
end

-- renders shadow
function occluder:renderShadow(lx, ly, lz, length, ox, oy)

    if aabb(lx, ly, 0, 0, self.position.x, self.position.y, self.w, self.h) then
        return
    end

    love.graphics.setColor(0, 0, 0)

    -- render poly shadows
    for i = 1, #self.matrix do
        local x1, y1, x2, y2 = unpack(self.matrix[i])
        x1, y1 = x1 + self.position.x, y1 + self.position.y
        x2, y2 = x2 + self.position.x, y2 + self.position.y

        local d1x, d1y = lx - x1, ly - y1
        local d2x, d2y = lx - x2, ly - y2
        local t1, t2 = math.atan2(d1y, d1x), math.atan2(d2y, d2x)

        local x3, y3 = math.cos(t2) * -2 * length + self.position.x, math.sin(t2) * -2 * length + self.position.y
        local x4, y4 = math.cos(t1) * -2 * length + self.position.x, math.sin(t1) * -2 * length + self.position.y

        love.graphics.polygon("fill", x1 + ox, y1 + oy, x2 + ox, y2 + oy, x3 + ox, y3 + oy, x4 + ox, y4 + oy)
    end

    love.graphics.setColor(1, 1, 1)

    love.graphics.rectangle("fill", self.position.x + ox, self.position.y + oy, self.w, self.h)
end

-- renders normal
function occluder:renderNormal(x, y, z, ox, oy)
    if not self.normal then return end

    _Shaders.normal:send("LightPos", {x, y, z})
    
    local shader = love.graphics.getShader()

    love.graphics.setShader(_Shaders.normal)

    love.graphics.draw(self.normal, self.position.x + ox, self.position.y + oy)

    love.graphics.setShader(shader)
end

-- renders glow
function occluder:renderGlow()
    if not self.glow then return end

    love.graphics.draw(self.glow, self.position.x, self.position.y)
end

-- draws texture
function occluder:drawTexture()
    if not self.texture then return end

    love.graphics.draw(self.texture, self.position.x, self.position.y)
end

-- sets texture
function occluder:setTexture(tex, resize)
    self.texture = tex

    if resize then
        self.w, self.h = tex:getWidth(), tex:getHeight()
        self:sizeMatrix(self.w, self.h)
    end
end

-- sets normal
function occluder:setNormal(normal)
    self.normal = normal
end

-- sets glow map
function occluder:setGlow(glow)
    self.glow = glow
end

-- checks if light in range
function occluder:inRange(lx, ly, d)
    local dsq = d * d
    for i = 1, #self.matrix do
        local px, py = self.matrix[i][1] + self.position.x, self.matrix[i][2] + self.position.y
        local dx, dy = px - lx, py - ly

        if dx * dx + dy * dy < dsq then return true end
    end

    return false
end

-- sets world
function occluder:setWorld(world)
    self.world = world
end

-- sets position
function occluder:setPosition(x, y)
    if x and not y then
        self.position = x
        return
    end

    self.position.x, self.position.y = x, y
end

-- resizes occluder
function occluder:setSize(w, h)
    self.w, self.h = w, h
    self:sizeMatrix(w, h)
end

-- resizes matrix
function occluder:sizeMatrix(w, h)
    self.matrix = Matrix {
        {0, 0, w, 0}, 
        {w, 0, w, h}, 
        {w, h, 0, h}, 
        {0, h, 0, 0}
    }
end

return occluder