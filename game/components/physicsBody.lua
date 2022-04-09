local comp = _Util.Object:new({
    embed = true,
    name = "physicsBody",
    requires = {}
})

function comp:init(x, y, w, h)
    self.moving = false
    self.remove = false

    self.position = _Util.Vector(x, y)
    self.velocity = _Util.Vector()
    self.direction = _Util.Vector()
    self.accellaration = _Util.Vector()

    self.w, self.h = w or 0, h or 0
end

function comp:getNextPosition() 
    return self.position + self.velocity 
end

-- apply an impulse to body
function comp:impulse(speed, dir, axis)
    self.direction[axis] = dir
    self.direction:unit()

    self.accellaration[axis] = self.direction[axis] * speed
end

-- update body
function comp:update(dt)
    -- basic move/slide logic
    self.accellaration = self.accellaration * _Constants.Friction
    self.velocity = self.velocity + self.accellaration
    self.velocity = self.velocity * dt
    self.position = self:getNextPosition()

    self.direction.x = 0
    self.direction.y = 0

    self.moving = (
        self.velocity.x < -0.0001 or self.velocity.x > 0.0001 or
        self.velocity.y < -0.0001 or self.velocity.y > 0.0001
    )
end

function comp:draw()
    love.graphics.rectangle("line", self.position.x, self.position.y, self.w, self.h)
end

return comp