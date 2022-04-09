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
    self.ongrid = false
end

function comp:onadd()
    local body = self.parent.physicsBody
    local Tilesize = _Constants.Tilesize
    local pos = body.position

    -- set positional data
    self.w, self.h = ceil(body.w / Tilesize) + 1, ceil(body.h / Tilesize) + 1
    self.origin.x, self.origin.y = floor(pos.x / Tilesize), floor(pos.y / Tilesize)

    self:applyVerteces()
end

function comp:onremove() 
    self.ongrid = true
    self:applyVerteces()
end

-- calculates verteces and adds them to grid
function comp:applyVerteces()
    local z = self.parent.layer

    -- x axis
    for x = 1, self.w do
        for y = 1, self.h do
            local px, py = self.origin.x + x, self.origin.y + y

            self:updateGridCoords(px, py, z)
        end
    end

    self.ongrid = not self.ongrid
end

-- updates world grid
function comp:updateGridCoords(x, y, z)
    local world = self.parent.world

    if not self.ongrid then world.grid:add(self.parent.id, x, y, z, self.parent.gridIndex) end
    if self.ongrid then world.grid:remove(x, y, z, self.parent.gridIndex) end
end

-- updates grid component
function comp:update(dt)
    -- if not self.parent.physicsBody.moving then return end

    self:applyVerteces()

    local Tilesize = _Constants.Tilesize
    local pos = self.parent.physicsBody.position

    self.origin.x, self.origin.y = floor(pos.x / Tilesize), floor(pos.y / Tilesize)

    self:applyVerteces()
end

function comp:draw()
end

return comp