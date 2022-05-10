local ceil, floor = math.ceil, math.floor
local body = Object:new()

function body:init(x, y, w, h, settings)
    local w, h = w or 0, h or 0

    self.position = Vector(x, y)
    self.offset = Vector()
    self.w, self.h = w or 0, h or 0

    self.occlude = true

    -- optional
    self.texture = nil
    self.normal = nil
    self.glow = nil

    self.alpha = 1
    self.alphaTick = 0
    self.fadeout = false

    -- glow settings
    self.doGlow = true

    for name, val in pairs(settings or {}) do
        self[name] = val
    end

    self:sizeMatrix(self.w, self.h)
end

-- renders shadow
function body:renderShadow(lx, ly, length, ox, oy)
    if not self.occlude then return end

    local px, py = self.position.x, self.position.y

    if aabb(lx, ly, 0, 0, px + (self.offset.x), py + (self.offset.y), self.w, self.h) then
        return
    end

    love.graphics.setColor(0, 0, 0, self.alpha)

    -- render poly shadows
    for i = 1, #self.matrix do
        local x1, y1, x2, y2 = unpack(self.matrix[i])
        x1, y1 = x1 + self.position.x, y1 + self.position.y
        x2, y2 = x2 + self.position.x, y2 + self.position.y

        local d1x, d1y = (lx - x1) , (ly - y1) 
        local d2x, d2y = (lx - x2) , (ly - y2) 
        local t1, t2 = math.atan2(d1y, d1x), math.atan2(d2y, d2x)

        local x3, y3 = (math.cos(t2) * -2 * length + self.position.x), (math.sin(t2) * -2 * length + self.position.y)
        local x4, y4 = (math.cos(t1) * -2 * length + self.position.x), (math.sin(t1) * -2 * length + self.position.y)

        x1, x2, x3, x4 = x1, x2, x3, x4
        y1, y2, y3, y4 = y1, y2, y3, y4

        love.graphics.polygon("fill", x1 + ox, y1 + oy, x2 + ox, y2 + oy, x3 + ox, y3 + oy, x4 + ox, y4 + oy)
    end

    love.graphics.setColor(1, 1, 1)
end

-- renders normal
function body:renderNormal(ox, oy)
    if not self.normal or self.fadeout then return false end

    love.graphics.draw(self.normal, self.position.x + (ox or 0), self.position.y + (oy or 0))
end

-- renders glow
function body:renderGlow(time)
    if not self.glow or self.fadeout then return false end


    _Shaders.glow:send("glowTime", time)
    _Shaders.glow:send("glowImage", self.glow)

    -- renders object glow
    love.graphics.setShader(_Shaders.glow)

        if self.doGlow then 
            self:renderTexture()
        else
            love.graphics.rectangle("fill", self.position.x, self.position.y, self.texture:getWidth(), self.texture:getHeight())
        end

    love.graphics.setShader()

    love.graphics.setColor(1, 1, 1)
end

-- draws texture
function body:renderTexture(world)
    if not self.texture then return false end

    -- check for fadeout and kill
    if self.fadeout then
        self.alpha = self.alpha - (self.alphaTick / 10) * love.timer.getDelta()
        self.alphaTick = self.alphaTick + 1

        if self.alpha <= 0 and world then
            world:removeBody(self)

            return true
        end
    end

    local r, g, b, a = love.graphics.getColor()
    love.graphics.setColor(r, g, b, self.alpha)

    love.graphics.draw(self.texture, self.position.x, self.position.y)

    love.graphics.setColor(r, g, b, a)

    return true
end

-- sets texture
function body:setTexture(tex, resize)
    self.texture = tex

    if resize then
        self.w, self.h = tex:getWidth(), tex:getHeight()
        self:sizeMatrix(self.w, self.h)
    end
end

-- sets normal
function body:setNormal(normal)
    self.normal = normal
end

-- sets glow map
function body:setGlow(glow)
    self.glow = glow
end

-- sets glow color
function body:setGlowColor(r, g, b)
    self.glowColor[1] = r or self.glowColor[1]
    self.glowColor[2] = g or self.glowColor[2]
    self.glowColor[3] = b or self.glowColor[3]
end

-- checks if light in range
function body:inRange(lx, ly, d)
    local px, py = self.position.x, self.position.y
    return aabb(px, py, self.w, self.h, lx - d, ly - d, d * 2, d * 2) or (self.w == 0 and self.h == 0)
end

-- sets world
function body:setWorld(world)
    self.world = world
end

-- sets position
function body:setPosition(x, y)
    self.position.x, self.position.y = x, y

    self.position:floor()
end

-- resizes body
function body:setSize(w, h)
    self.w, self.h = w, h
    self:sizeMatrix(w, h)
end

-- resizes matrix
function body:sizeMatrix(w, h, ox, oy)
    local ox, oy = ox or self.offset.x, oy or self.offset.y

    self.matrix = Matrix {
        {ox, oy, w + ox, oy}, 
        {w + ox, oy, w + ox, h + oy}, 
        {w + ox, h + oy, ox, h + oy}, 
        {ox, h + oy, ox, oy}
    }
end

function body:fadeKill()
    self.fadeout = true
end

return body