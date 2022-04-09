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

    self.origin = _Util.Vector()
    self.w, self.h = -1, -1
end

-- executes addition of component
function comp:onadd()
    local body = self.parent.physicsBody
    local Tilesize = _Constants.Tilesize

    -- set positional data
    self.w, self.h = ceil(body.w / Tilesize) + 1, ceil(body.h / Tilesize) + 1
    local pos = self.parent.physicsBody.gridPosition
    self.origin.x, self.origin.y = pos.x, pos.y

    self:applyVerteces(false)
end

-- executes on removal of component
function comp:onremove() 
    self.ongrid = true
    self:applyVerteces()
end

-- updates world grid
function comp:updateGridCoords(x, y, z, remove)
    local world = self.parent.world

    if remove == false then world.grid:add(self.parent.id, x, y, z, self.parent.gridIndex) end
    if remove == true then world.grid:remove(x, y, z, self.parent.gridIndex) end
end

-- calculates verteces and adds them to grid
function comp:applyVerteces(remove)
    local z = self.parent.layer

    -- x axis
    for x = 0, self.w - 1 do
        for y = 0, self.h - 1 do

            self:updateGridCoords(self.origin.x + x, self.origin.y + y, z, remove)
        end
    end
end

-- updates grid component
function comp:update(dt)
    if not self.parent.physicsBody.moving then return end

    self:applyVerteces(true)

    local ox, oy = self.origin.x, self.origin.y

    local pos = self.parent.physicsBody.gridPosition
    self.origin.x, self.origin.y = pos.x, pos.y

    self:applyVerteces(false)
end

function comp:draw()
end

return comp