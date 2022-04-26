local light = Object:new()

function light:init(x, y, range, color)
    self.position = Vector(x, y); self.position.z = 1
    self.color = color or {1, 1, 1}
    self.range = range or 0
    self.world = nil

    self.moved = true

    self:sizeBuffer()
end

-- defines buffer
function light:sizeBuffer()
    local w, h = self.range * 2 * _Screen.ResolutionScaling, self.range * 2 * _Screen.ResolutionScaling

    self.buffer = love.graphics.newCanvas(w, h)
    self.shadowBuffer = love.graphics.newCanvas(w, h)

    -- self.buffer:setFilter("nearest", "nearest")
end

-- updates shadow buffer
function light:updateShadowBuffer(f, tx, ty, ...)
    local canvas = love.graphics.getCanvas()
    local blendMode = love.graphics.getBlendMode()
    love.graphics.setCanvas(self.shadowBuffer)
    love.graphics.origin()

    love.graphics.setBlendMode("alpha")

    f(...)

    love.graphics.setCanvas(canvas)
    love.graphics.setBlendMode(blendMode)
end

function light:update(dt, tx, ty)
    local bw, bh = self.shadowBuffer:getWidth(), self.shadowBuffer:getHeight()

    -- pass info onto shader
    _Shaders.light:send("Radius", self.range * _Screen.ResolutionScaling)
    _Shaders.light:send("Position", {(bw / 2), (bh / 2), self.position.z})
    _Shaders.blur:send("Size", {bw, bh})

    local buffer = love.graphics.getCanvas()

    -- draw to buffer
    love.graphics.setCanvas(self.buffer)
        love.graphics.clear(0, 0, 0)
        love.graphics.origin()

        love.graphics.setShader(_Shaders.light)

        -- draw light
        love.graphics.circle("fill", bw / 2, bh / 2, self.range)

        love.graphics.setShader()

        -- subtract shadows from light
        love.graphics.setBlendMode("multiply", "premultiplied")

            -- love.graphics.setShader(_Shaders.blur)

            love.graphics.draw(self.shadowBuffer)

            -- love.graphics.setShader()

        love.graphics.setBlendMode("alpha")

    love.graphics.setCanvas(buffer)

    self.moved = false
end

function light:draw()
    local rx, ry = _Screen.ResolutionScaling, _Screen.ResolutionScaling

    love.graphics.setColor(unpack(self.color))

    love.graphics.draw(self.buffer, (self.position.x - self.range) * rx, (self.position.y - self.range) * ry)

    love.graphics.setColor(1, 1, 1)

    local buffer = love.graphics.getCanvas()

    love.graphics.setCanvas(self.shadowBuffer); love.graphics.clear(1, 1, 1)

    love.graphics.setCanvas(buffer)

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