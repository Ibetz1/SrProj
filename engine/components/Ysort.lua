local comp = Object:new({
    embed = false,
    type = "Ysort",
    name = "Ysorter",
    requires = {
        "gridUpdater",
        "texture"
    }
})

function comp:init()

end

function comp:update(dt)
    local cast = self.parent.physicsGridUpdater.cast
    local world = self.parent.world
    local body = self.parent.Body
    local tex = self.parent.texture

    for _, id in pairs(cast) do
        local ent = world:getEntity(id)

        if not ent then goto next end
        if not ent.texture then goto next end
        if not ent.Body then goto next end

        local py = ent.Body.position.y + ent.Body.h

        if body.position.y + body.h > py then
            if ent.texture.body.index > tex.body.index then
                world:swapOccluders(ent.texture.body, self.parent.texture.body)
                
            end
        end
        
        ::next::
    end
end

return comp