local comp = _Util.Object:new({
    name = "rigidBody",
    embed = false,
    requires = {
        "physicsBody",
        "worldGridUpdater"
    }
})

function comp:init() 
    self.preCollide = _Util.Vector()
end

function comp:onadd()
    function self.parent.physicsBody:getNextPosition()
        return self.position + self.velocity
    end
end

function comp:isColliding(x, y, w, h)
    local physicsBody = self.parent.physicsBody
    local px, py, w1, h1 = physicsBody.position.x, physicsBody.position.y, physicsBody.w, physicsBody.h

    return x + w > px and 
           x < px + w1 and
           y + w > py and
           y < py + h1
end

-- gets all objects at specified grid location
function comp:objectsAtLocation(x, y)
    local grid = self.parent.world.grid
    return grid:get(x, y, self.parent.layer)
end

function comp:update(dt)

end

function comp:draw()
end

return comp