local comp = _Util.Object:new({
    embed = true,
    name = "occluder",
    type = "occluder",
    requires = {
        {"physicsBody", "worldBody"},
        "texture"
    }
})

function comp:init()
    self.body = nil
end

function comp:onadd()
    local lm = self.parent.world.lightWorld
    local tex = self.parent.texture
    local body = self.parent.Body

    self.body = lm:newImage(tex.image)

    if tex.glow then self.body:setGlowMap(tex.glow) end
    if tex.normal then self.body:setNormalMap(tex.normal) end

    self.parent.hasOccluder = true
end

function comp:update(dt)
    local pos = self.parent.Body.position
    local tex = self.parent.texture
    self.body:setPosition(pos.x + tex.w / 2, pos.y + tex.h / 2)
end

return comp