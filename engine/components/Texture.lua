local comp = _Util.Object:new({
    embed = true,
    name = "texture",
    type = "texture",
    requires = {
        {"worldBody", "physicsBody"}
    }
})

function comp:init(image, normal, glow)
    self.remove = false

    self.image = image
    self.normal = normal
    self.glow = glow

    if image then
        self.w = image:getWidth()
        self.h = image:getHeight()
    end

    self.scale = 1
end

function comp:onadd()
    if not self.w then
        self.w = self.parent.Body.w
        self.h = self.parent.Body.h
    end
end

-- sets glow map
function comp:setGlowMap(glow)
    self.glow = glow
end

-- sets normal map
function comp:setNormalMap(normal)
    self.normal = normal
end

-- sets image
function comp:setImage(image)
    self.image = image
end

-- scales image
function comp:scale(scale)
    self.scale = scale
end


function comp:draw()
    local body = self.parent.Body
    local px, py = body.position.x, body.position.y

    love.graphics.draw(self.image, px, py, 0, self.scale)
end

return comp