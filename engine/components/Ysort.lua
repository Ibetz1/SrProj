local comp = _Util.Object:new({
    embed = false,
    type = "Ysort",
    name = "Ysorter",
    requires = {
        "gridUpdater"
    }
})

function comp:init()

end

function comp:update(dt)
    local cast = self.parent.physicsGridUpdater.cast
    local world = self.parent.world
    local body = self.parent.Body

    for _, id in pairs(cast) do
        local ent = world:getEntity(id)
        if not ent.Body then goto next end

        local py = ent.Body.position.y + ent.Body.h

        if body.position.y + body.h > py then

            -- sort textures
            if self.parent.drawLayer < ent.drawLayer then
                world:swapDrawOrder(ent, self.parent)
            end

            -- check for occluders
            local occ1, occ2 = self.parent.occluder, ent.occluder
            if not occ1 or not occ2 then goto next end

            local id1, id2 = occ1.body.id, occ2.body.id
        
            if id2 > id1 then

                world:swapOccluders(occ1.body, occ2.body)
            end

            ::next::
        end
        
        ::next::
    end
end

return comp