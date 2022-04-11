local ceil, floor = math.ceil, math.floor

local comp = _Util.Object:new({
    name = "worldGridUpdater",
    embed = true,
    requires = {
        "physicsBody"
    }
})

function comp:init()
    self.remove = false

    self.w, self.h = -1, -1
end

-- executes addition of component
function comp:onadd()
    local body = self.parent.physicsBody
    local Tilesize = _Constants.Tilesize

    -- set positional data
    self.w, self.h = ceil(body.w / Tilesize) + 1, ceil(body.h / Tilesize) + 1

    self:updateGrid(
        body.gridPosition.x, body.gridPosition.y,
        body.gridPosition.x, body.gridPosition.y
    )
end

-- executes on removal of component
function comp:onremove() 
    local body = self.parent.physicsBody

    self:updateGrid(
        body.gridPosition.x, body.gridPosition.y,
        body.gridPosition.x, body.gridPosition.y,
        true
    )
end

-- remaps grid coordinates
function comp:updateGrid(x1, y1, x2, y2, remove)
    local world = self.parent.world
    local z = self.parent.layer

    -- update the coordinate on grid
    for x = 0, self.w - 1 do
        for y = 0, self.h - 1 do
            world.physicsGrid:remove(x1 + x, y1 + y, z, self.parent.gridIndex)
            
            if not remove then 
                world.physicsGrid:add(self.parent.id, x2 + x, y2 + y, z, self.parent.gridIndex)
            end
        end
    end
end

-- updates grid component
function comp:update(dt)
    local world = self.parent.world

    local body = self.parent.physicsBody
    local x1, y1 = body.gridPosition.x, body.gridPosition.y
    local x2, y2 = world.physicsGrid:map(body.position.x + body.velocity.x, body.position.y + body.velocity.y)

    self:updateGrid(x1, y1, x2, y2)
end

function comp:draw()
end

return comp