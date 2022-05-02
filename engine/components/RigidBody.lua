local comp = Object:new({
    name = "rigidBody",
    type = "collider",
    embed = false,
    requires = {
        "physicsBody",
        "gridUpdater"
    }
})

function comp:init()
    self.clippingDistance = Vector()

    self.gridOrigin = Vector()
    self.tileWidth, self.tileHeight = -1, -1
end

function comp:onadd()
    -- redfine the onmove function
    function self.parent.Body.getNextPosition(body, offset)
        if body.properties.static or not body.clip then return body.position + offset end

        -- calculate collisions
        self:moveAndSlide(body, offset)

        return body.position + offset - self.clippingDistance
    end
end

-- applies collision clipping
function comp:moveAndSlide(body, realOffset)
    local world = self.parent.world

    local pos = body.position
    local cast = self.parent.physicsGridUpdater.cast

    -- check ray cast for other entities
    for _, id in pairs(cast) do
        local obj = world:getEntity(id)
        
        if not obj or not obj.components.rigidBody then goto next end
        if obj.Body.properties.static and not body.collideStatic then goto next end

        -- get clipping distance
        local collision, dir = self:resolveCollision(pos.x + realOffset.x, pos.y + realOffset.y, obj.components.rigidBody)


        -- static collision event
        if not self.parent.Body.properties.static and obj.Body.properties.static and collision then
            
            globalEventHandler:toggle("staticCollision", self.parent.id, obj.id, dir)

        end

        ::next::
    end
end

-- gets clip from cast
function comp:resolveCollision(x1, y1, obj)

    local body, objBody = self.parent.Body, obj.parent.Body

    if not objBody.clip then return false end

    local w1, h1, w2, h2 = body.w, body.h,  objBody.w, objBody.h
    local x2, y2 = objBody.position.x, objBody.position.y

    local dir = body.direction

    -- return clipping distance
    if aabb(x1, y1, w1, h1, x2, y2, w2, h2) then

        local dx = ((x1 + w1 / 2) - (x2 + w2 / 2)) / (w1 + w2) / 2
        local dy = ((y1 + h1 / 2) - (y2 + h2 / 2)) / (h1 + h2) / 2

        -- horizontal collision case
        if math.abs(dx) > math.abs(dy) then
            -- left case
            if dx < 0 then self.clippingDistance.x = x1 + w1 - x2

            -- right case
            else self.clippingDistance.x = -(x2 + w2 - x1) end

            -- apply velocity
            if objBody.properties.static then return true, Vector(dir.x, 0) end

            local speed = math.abs(body.accellaration.x * 1 / _Constants.Friction) / objBody.properties.mass

            objBody:impulse(speed, dir.x, "x")

        -- verticle collision case
        else
            -- top case
            if dy < 0 then self.clippingDistance.y = y1 + h1 - y2

            -- bottom case
            else self.clippingDistance.y = -(y2 + h2 - y1) end

            -- apply velocity
            if objBody.properties.static then return true, Vector(0, dir.y) end

            local speed = math.abs(body.accellaration.y * 1 / _Constants.Friction) / objBody.properties.mass

            objBody:impulse(speed, dir.y, "y")
        end

        return true, dir
    end

    
end

function comp:update(dt)

    self.clippingDistance:zero()
end

function comp:draw()
    
end

return comp