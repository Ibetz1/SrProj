local light = Object:new()

function light:init(x, y, range, color)
    self.position = Vector(x, y); self.position.z = 1
    self.color = color or {1, 1, 1}
    self.range = range or 0
    self.world = nil

    self.buffer = love.graphics.newCanvas(range * 2, range * 2)
    self.shadowBuffer = love.graphics.newCanvas(range * 2, range * 2)
    self.normalBuffer = love.graphics.newCanvas(range * 2, range * 2)
end

-- updates shadow buffer
function light:updateShadowBuffer(f, ...)
    local canvas = love.graphics.getCanvas()
    love.graphics.setCanvas(self.shadowBuffer)

    f(...)

    love.graphics.setCanvas(canvas)
end

function light:update(dt)
    -- pass info onto shader
    _Shaders.light:send("Radius", self.range)
    _Shaders.light:send("Position", {self.range, self.range, self.position.z})

    local buffer = love.graphics.getCanvas()
    love.graphics.setCanvas(self.buffer)
        love.graphics.clear(0, 0, 0)

        love.graphics.setShader(_Shaders.light)

        -- draw light
        love.graphics.circle("fill", self.range, self.range, self.range)

        love.graphics.setShader()

        -- subtract shadows from light
        love.graphics.setBlendMode("multiply", "premultiplied")

        love.graphics.draw(self.shadowBuffer)

        love.graphics.setBlendMode("alpha")

    love.graphics.setCanvas(buffer)
end

function light:draw()
    love.graphics.setColor(unpack(self.color))

    love.graphics.draw(self.buffer, self.position.x - self.range, self.position.y - self.range)

    love.graphics.setColor(1, 1, 1)

    local buffer = love.graphics.getCanvas()

    love.graphics.setCanvas(self.shadowBuffer); love.graphics.clear(1, 1, 1)

    love.graphics.setCanvas(buffer)
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

return light