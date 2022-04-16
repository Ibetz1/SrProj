local light = Object:new()

function light:init(x, y, range, color)
    self.position = Vector(x, y); self.position.z = 1
    self.color = color or {1, 1, 1}
    self.range = range or 0
    self.world = nil
end

function light:update(dt)
    -- pass info onto shader
    _Shaders.light:send("Radius", self.range)
    _Shaders.light:send("Position", {self.position.x, self.position.y, self.position.z})
end

function light:draw()
    love.graphics.setColor(unpack(self.color))

    love.graphics.setShader(_Shaders.light)

    -- draw light
     love.graphics.circle("fill", self.position.x, self.position.y, self.range)

    love.graphics.setShader()

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

return light