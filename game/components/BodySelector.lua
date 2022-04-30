local comp = Object:new({
    embed = true,
    name = "BodySelector",
    type = "BodySelector",
    requires = {
        "texture"
    }
})

function comp:init()
    self.hover = false
end

function comp:onadd()
end

function comp:update()
    local world = self.parent.world
    local body = self.parent.texture.body

    local mx, my = world:convertScreenCoord(love.mouse.getPosition())
    local px, py = body.position:unpack()
    local w, h = body.w, body.h

    self.hover = aabb(px, py, w, h, mx, my, 0, 0)
    body.doGlow = self.hover or (_Game.selected == self.parent.id)

    if self.hover then
        if love.mouse.isDown(1) then
            _Game.selected = self.parent.id
        end
    end
end

function comp:draw() end

return comp