local comp = _Util.Object:new({
    embed = true,
    name = "Body",
    type = "worldBody",
    requires = {},
    exclude = {
        "physicsBody"
    }
})

function comp:init(x, y, w, h)
    self.remove = false

    self.position = _Util.Vector(x, y)
    self.gridPosition = _Util.Vector()
    self.w, self.h = w or 0, h or 0
end

function comp:onadd()
    self.gridPosition.x, self.gridPosition.y = self.parent.world.physicsGrid:map(self.position.x, self.position.y)
end

-- sets position of entity
function comp:setPosition(x, y)
    self.position.x, self.position.y = x, y
end

-- moves world body
function comp:move(dx, dy)
    self.position.x = self.position.x + dx
    self.position.y = self.position.y + dy
end

-- update body
function comp:update(dt)
    self.gridPosition.x, self.gridPosition.y = self.parent.world.physicsGrid:map(self.position.x, self.position.y)
end

function comp:draw()
end

return comp