local function aabb(x1, y1, w1, h1, x2, y2, w2, h2)
    return x1 < x2 + w2 and
           x1 + w1 > x2 and
           y1 < y2 + h2 and
           y1 + h1 > y2
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
    self.collisions = {}
    self.clippingDistance = _Util.Vector()
end

function comp:onadd()


    function self.parent.physicsBody.getNextPosition(body)
        if body.velocity.x and body.velocity.y == 0 then return body.position end

        local gridUpdater = self.parent.worldGridUpdater

        local pos = body.position
        local vel = body.velocity

        local world = self.parent.world
        local grid = world.grid

        local px, py = grid:map(pos.x + vel.x, pos.y + vel.y)
        local pz = self.parent.layer

        for x = 0, gridUpdater.w - 1 do
            for y = 0, gridUpdater.h - 1 do
                local px, py = px + x, py + y

                local cast = grid:get(px, py, pz)

                for _, id in pairs(cast) do
                    if id ~= self.parent.id then
                        local obj = world:getEntity(id)

                        if not obj.components.rigidBody then goto next end

                        self:getClipDistance(pos.x + vel.x, pos.y + vel.y, obj.components.rigidBody)
                        ::next::
                    end
                end

            end
        end

        return body.position + body.velocity - self.clippingDistance
    end
end

-- gets clip from cast
function comp:getClipDistance(x1, y1, obj)
    local body, objBody = self.parent.physicsBody, obj.parent.physicsBody

    if not objBody then return end

    local w1, h1, w2, h2 = body.w, body.h,  objBody.w, objBody.h
    local x2, y2 = objBody.position.x, objBody.position.y

    -- return clipping distance
    if aabb(x1, y1, w1, h2, x2, y2, w2, h2) then
        local cx, cy = 0, 0

        local dx = (x1 + w1 / 2) - (x2 + w2 / 2)
        local dy = (y1 + h1 / 2) - (y2 + h2 / 2)

        -- horizontal collision case
        if math.abs(dx) > math.abs(dy) then
            -- left case
            if dx < 0 then
                self.clippingDistance.x = x1 + w1 - x2
            else
                self.clippingDistance.x = -(x2 + w2 - x1)
            end

        -- verticle collision case
        else
            if dy < 0 then
                self.clippingDistance.y = y1 + h1 - y2
            else
                self.clippingDistance.y = -(y2 + h2 - y1)
            end

        end
    end
end

function comp:update(dt)
    self.clippingDistance.x, self.clippingDistance.y = 0, 0

end

function comp:draw()
    
end

return comp