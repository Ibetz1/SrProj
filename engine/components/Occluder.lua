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
    self.pos = _Util.Vector()
end

function comp:onadd()
    local lm = self.parent.world.lightWorld
    local tex = self.parent.texture

    self.body = lm:newImage(tex.image)
    self.body:setLayer(self.parent.layer, lm)

    self.w, self.h = tex.w, tex.h

    if tex.glow then self.body:setGlowMap(tex.glow) end
    if tex.normal then self.body:setNormalMap(tex.normal) end

    self.parent.hasOccluder = true
end

-- sets draw order for occluder
function comp:setIndex(index)
    local lm = self.parent.world.lightWorld
    local oldIndex = self.body.id

    if index == oldIndex then return end

    lm[index], lm[oldIndex] = lm[oldIndex], nil
    self.body.id = index
end

function comp:draw(dt)
    local tex = self.parent.texture
    local pos = self.parent.Body.position

    self.body:setPosition(pos.x + tex.w / 2, pos.y + tex.h / 2)
end

return comp