local comp = _Util.Object:new({
    embed = true,
    name = "Body",
    type = "physicsBody",
    requires = {},
    exclude = {
        "worldBody"
    }
})

function comp:init(x, y, w, h, properties)
    self.moving = false
    self.remove = false

    self.position = _Util.Vector(x, y)
    self.velocity = _Util.Vector()
    self.direction = _Util.Vector()
    self.accellaration = _Util.Vector()

    self.gridPosition = _Util.Vector()
    self.positionOffset = _Util.Vector()

    self.properties = {
        mass = 1,
        static = false
    }

    if properties then
        for k,v in pairs(properties) do
            self.properties[k] = v
        end
    end

    self.w, self.h = w or 0, h or 0
end

function comp:onadd()
    self.gridPosition.x, self.gridPosition.y = self.parent.world.physicsGrid:map(self.position.x, self.position.y)
end

-- default function for clipping (overridden by rigid body)
function comp:getNextPosition(offset)
    return self.position + offset
end

-- apply an impulse to body
function comp:impulse(speed, dir, axis)
    self.direction[axis] = dir
    self.direction:unit()

    self.accellaration[axis] = self.direction[axis] * speed
end

-- sets position of component
function comp:setPosition(x, y)
    self.positionOffset.x = x - self.position.x
    self.positionOffset.y = y - self.position.y

    self.position = self:getNextPosition(self.positionOffset)
end

-- update body
function comp:update(dt)
    self.gridPosition.x, self.gridPosition.y = self.parent.world.physicsGrid:map(self.position.x, self.position.y)

    -- basic move/slide logic
    self.accellaration = self.accellaration * _Constants.Friction

    self.velocity = (self.velocity + self.accellaration) * dt

    if math.abs(self.velocity.x) < 0.0001 then self.velocity.x = 0 end
    if math.abs(self.velocity.y) < 0.0001 then self.velocity.y = 0 end

    self.position = self:getNextPosition(self.velocity)

    self.direction.x = 0
    self.direction.y = 0

    self.moving = (
        self.velocity.x < -0.0001 or self.velocity.x > 0.0001 or
        self.velocity.y < -0.0001 or self.velocity.y > 0.0001
    )
end

function comp:draw()
    love.graphics.line(
        self.position.x + self.w / 2, self.position.y + self.h / 2,
        self.position.x + self.w / 2+ self.velocity.x * 10,
        self.position.y + self.h / 2+ self.velocity.y * 10
    )

    love.graphics.rectangle("line", self.position.x, self.position.y, self.w, self.h)
end

return comp