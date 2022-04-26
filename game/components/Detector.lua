local comp = _Util.Object:new({
    name = "detector",
    type = "spacialDetector",
    embed = false,
    requires = {
        {"WorldBody", "PhysicsBody"},
        "physicsGridUpdater"
    }
})

function comp:init()
    self.detected = {}
end

function comp:update()
    self.detected = {}

    local world = self.parent.world

    local body = self.parent.Body
    local pos = body.position
    local cast = self.parent.physicsGridUpdater.cast

    -- check ray cast for other entities
    for _, id in pairs(cast) do
        local obj = world:getEntity(id)

        if not (obj.components.worldBody or obj.components.rigidBody) then goto next end

        local px, py = obj.Body.position.x, obj.Body.position.y
        local w, h = obj.Body.w, obj.Body.h

        -- detect entity
        if aabb(pos.x, pos.y, body.w, body.h, px, py, w, h) then
            table.insert(self.detected, id)
        end

        ::next::
    end
end

return comp