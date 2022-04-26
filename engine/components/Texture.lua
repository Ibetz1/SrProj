local comp = Object:new({
    embed = true,
    name = "texture",
    type = "texture",
    requires = {
        {"worldBody", "physicsBody"}
    }
})

function comp:init(image, normal, glow, settings)
    self.remove = false
    
    self.body = _Lighting.Body(0, 0, 0, 0, settings)

    -- set textures
    self:setGlowMap(glow)
    self:setNormalMap(normal)
    self:setImage(image)
end

function comp:onadd()
    self.parent.world.lightWorld:addBody(self.body)
end

function comp:resizeOccluder(w, h)
    self.body:setSize(w, h)
end

-- defines occlusion boundries
function comp:defineOccluder(w, h, ox, oy)
    self.body.w, self.body.h = w, h
    self.body.offset.x, self.body.offset.y = ox or 0, oy or 0
end

-- updates body
function comp:update()
    local pos = self.parent.Body.position
    self.body:setPosition(pos.x, pos.y)
end

-- mapping functions
function comp:setGlowMap(glow) self.body:setGlow(glow) end
function comp:setNormalMap(normal) self.body:setNormal(normal) end
function comp:setImage(image) self.body:setTexture(image) end

return comp