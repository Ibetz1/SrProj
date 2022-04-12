local ceil, floor = math.ceil, math.floor

local comp = _Util.Object:new({
    name = "physicsGridUpdater",
    type = "gridUpdater",
    embed = true,
    requires = {
        "physicsBody"
    }
})

function comp:init()
    self.remove = false
    self.cast = {}

    self.w, self.h = -1, -1
end

-- executes addition of component
function comp:onadd()
    local body = self.parent.Body
    local Tilesize = _Constants.Tilesize

    -- set positional data
    self.w, self.h = ceil(body.w / Tilesize) + 2, ceil(body.h / Tilesize) + 2

    self:updateGrid(
        body.gridPosition.x, body.gridPosition.y,
        body.gridPosition.x, body.gridPosition.y
    )
end

-- executes on removal of component
function comp:onremove() 
    local body = self.parent.Body

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
            world.physicsGrid:remove(x1 + x, y1 + y, z, self.parent.layerDepth)

            if not remove then

                -- get all surrounding entities
                local cast = world.physicsGrid:get(x2 + x, y2 + y, z)
                for _, id in pairs(cast) do
                    if id ~= self.parent.id then table.insert(self.cast, id) end
                end

                world.physicsGrid:add(self.parent.id, x2 + x, y2 + y, z, self.parent.layerDepth)
            end
        end
    end
end

-- updates grid component
function comp:update(dt)
    local world = self.parent.world

    local body = self.parent.Body
    local x1, y1 = body.gridPosition.x, body.gridPosition.y
    local x2, y2 = world.physicsGrid:map(body.position.x + body.velocity.x, body.position.y + body.velocity.y)

    for index, _ in pairs(self.cast) do
        self.cast[index] = nil
    end

    self:updateGrid(x1, y1, x2, y2)
end

function comp:draw()
end

return comp