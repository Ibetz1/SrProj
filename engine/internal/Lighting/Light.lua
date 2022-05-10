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

    self.shadowBuffer = love.graphics.newCanvas(w, h)
    self.normalBuffer = love.graphics.newCanvas(w, h)
end

-- updates shadow buffer
function light:updateShadowBuffer(f, ...)
    local canvas = love.graphics.getCanvas()
    local blendMode = love.graphics.getBlendMode()

    love.graphics.setCanvas(self.shadowBuffer)
        love.graphics.origin()
        love.graphics.clear(1, 1, 1)

        -- update shadows
        love.graphics.setBlendMode("alpha")

        f(...)

        love.graphics.setBlendMode(blendMode)
    love.graphics.setCanvas(canvas)
end

-- updates normal buffer
function light:updateNormalBuffer(f, ...)
    local canvas = love.graphics.getCanvas()
    local blend  = love.graphics.getBlendMode()

    love.graphics.setCanvas(self.normalBuffer)
        love.graphics.origin()
        love.graphics.setBlendMode("alpha")
        love.graphics.clear()

        _Shaders.lightNormal:send("Radius", self.range)
        _Shaders.lightNormal:send("Position", {(self.range), (self.range), self.position.z})
        love.graphics.setShader(_Shaders.lightNormal)

        f(...)

        love.graphics.setShader()

        love.graphics.setBlendMode("multiply", "premultiplied")

        love.graphics.draw(self.shadowBuffer)

        love.graphics.setBlendMode(blend)
    love.graphics.setCanvas(canvas)
end

function light:draw()
    love.graphics.setColor(unpack(self.color))

    love.graphics.draw(self.normalBuffer, math.floor(self.position.x - self.range), math.floor(self.position.y - self.range))

    love.graphics.setColor(1, 1, 1)
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