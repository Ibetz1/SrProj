local comp = _Util.Object:new({
    name = "detector",
    type = "spacialDetector",
    embed = false,
    requires = {
        {"worldBody", "physicsBody"},
        "gridUpdater"
    }
})

function comp:init()
    self.detected = {}
end

function comp:onremove()
    if _Game.selected == self.parent.id then
        _Game.selected = nil
    end
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

        if not obj then goto next end
        if obj.id == self.parent.id then goto next end

        if not (obj.components.worldBody or obj.components.rigidBody) then goto next end

        local px, py = obj.Body.position.x, obj.Body.position.y
        local w, h = obj.Body.w, obj.Body.h

        -- detect entity
        if aabb(pos.x + body.w / 2, pos.y + body.h / 2, 0, 0, px, py, w, h) and obj.Body.clip then

            world:removeEntity(id)

            _Game.remainingBlocks = _Game.remainingBlocks - 1

        end

        ::next::
    end
end

return comp