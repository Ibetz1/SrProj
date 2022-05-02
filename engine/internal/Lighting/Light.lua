local light = Object:new()

function light:init(x, y, range, color)
    self.position = Vector(x, y); self.position.z = 5
    self.color = color or {1, 1, 1}
    self.range = range or 0
    self.world = nil

    self.moved = true

    self:sizeBuffer()
end

-- defines buffer
function light:sizeBuffer()
    local w, h = self.range * 2, self.range * 2

    self.lightBuffer = love.graphics.newCanvas(w, h)
    self.shadowBuffer = love.graphics.newCanvas(w, h)

    -- self.buffer:setFilter("nearest", "nearest")

    -- render light
    love.graphics.setCanvas(self.lightBuffer)

        _Shaders.light:send("Radius", self.range)
        _Shaders.light:send("Position", {(w / 2), (h / 2), self.position.z})

        love.graphics.setShader(_Shaders.light)

        love.graphics.circle("fill", w / 2, h / 2, self.range)

        love.graphics.setShader()

    love.graphics.setCanvas()
end

-- updates shadow buffer
function light:updateShadowBuffer(f, tx, ty, ...)
    local canvas = love.graphics.getCanvas()
    local blendMode = love.graphics.getBlendMode()

    love.graphics.setCanvas(self.shadowBuffer)
        love.graphics.origin()
        love.graphics.clear(1, 1, 1)

        -- update shadows
        love.graphics.setBlendMode("alpha")

        f(...)

        love.graphics.setBlendMode("multiply", "premultiplied")

        love.graphics.draw(self.lightBuffer)

    love.graphics.setCanvas(canvas)
    love.graphics.setBlendMode(blendMode)
end

function light:draw()
    love.graphics.setColor(unpack(self.color))

    love.graphics.draw(self.shadowBuffer, (self.position.x - self.range), (self.position.y - self.range))
end

-- sets light positon
function light:setPosition(x, y, z)
    self.position.x = x or self.position.x
    self.position.y = y or self.position.y
    self.position.z = z or self.position.z

end

-- sets world
function light:setWorld(w) 
    self.world = w
end

-- sets color
function light:setColor(r, g, b)
    self.color[1] = r or self.color[1]
    self.color[2] = g or self.color[2]
    self.color[3] = b or self.color[3]
end

return light