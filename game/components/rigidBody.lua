local function aabb(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 + w1 >= x2 and 
           x1 <= x2 + w2 and
           y1 + h1 >= y2 and
           y1 <= y2 + h2
end

local comp = _Util.Object:new({
    name = "rigidBody",
    embed = false,
    requires = {
        "physicsBody",
        "worldGridUpdater"
    }
})

function comp:init()
    self.clippingDistance = _Util.Vector()

    self.gridOrigin = _Util.Vector()
    self.tileWidth, self.tileHeight = -1, -1
end

function comp:onadd()
    local world = self.parent.world
    local grid = world.physicsGrid

    -- redfine the onmove function
    function self.parent.physicsBody.getNextPosition(body)
        if body.properties.static then return body.position + body.velocity end

        -- define locals
        local gridUpdater = self.parent.worldGridUpdater

        -- iterate through occupied grid coordinates
        for x = 0, gridUpdater.w - 1 do
            for y = 0, gridUpdater.h - 1 do  
                self:moveAndSlide(body, x, y)
            end
        end

        return body.position + body.velocity - self.clippingDistance
    end
end

-- applies collision clipping
function comp:moveAndSlide(body, ox, oy)
    local world = self.parent.world
    local grid = world.physicsGrid

    local pos, vel = body.position, body.velocity

    local px, py = grid:map(pos.x + vel.x, pos.y + vel.y)
    local pz = self.parent.layer

    local cast = grid:get(px + ox, py + oy, pz)

    -- check ray cast for other entities
    for _, id in pairs(cast) do
        if id ~= self.parent.id then
            local obj = world:getEntity(id)

            if not obj.components.rigidBody then goto next end

            -- get clipping distance
            self:resolveCollision(pos.x + vel.x, pos.y + vel.y, obj.components.rigidBody)

            ::next::
        end
    end
end

-- gets clip from cast
function comp:resolveCollision(x1, y1, obj)
    local body, objBody = self.parent.physicsBody, obj.parent.physicsBody

    if not objBody then return end

    local w1, h1, w2, h2 = body.w, body.h,  objBody.w, objBody.h
    local x2, y2 = objBody.position.x, objBody.position.y

    -- return clipping distance
    if aabb(x1, y1, w1, h1, x2, y2, w2, h2) then
        local cx, cy = 0, 0

        local dx = (x1 + w1 / 2) - (x2 + w2 / 2)
        local dy = (y1 + h1 / 2) - (y2 + h2 / 2)

        -- horizontal collision case
        if math.abs(dx) > math.abs(dy) then
            -- left case
            if dx < 0 then self.clippingDistance.x = x1 + w1 - x2

            -- right case
            else self.clippingDistance.x = -(x2 + w2 - x1) end

            -- apply velocity
            if objBody.properties.static then return end

            local dir = body.direction.x
            local speed = math.abs(body.accellaration.x * 1 / _Constants.Friction) / objBody.properties.mass

            objBody:impulse(speed, dir, "x")

        -- verticle collision case
        else
            -- top case
            if dy < 0 then self.clippingDistance.y = y1 + h1 - y2

            -- bottom case
            else self.clippingDistance.y = -(y2 + h2 - y1) end

            -- apply velocity
            if objBody.properties.static then return end

            local dir = body.direction.y
            local speed = math.abs(body.accellaration.y * 1 / _Constants.Friction) / objBody.properties.mass

            objBody:impulse(speed, dir, "y")
        end
    end
end

function comp:update(dt)
    self.clippingDistance:zero()
end

function comp:draw()
    
end

return comp