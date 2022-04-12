local comp = _Util.Object:new({
    embed = true,
    name = "texture",
    type = "texture",
    requires = {
        {"worldBody", "physicsBody"}
    }
})

function comp:init(tex, scale)
    self.remove = false

    self.texture = tex
    self.scale = scale or 1
end

function comp:scale(scale)
    self.scale = scale
end


function comp:draw()
    local body = self.parent.Body
    local px, py = body.position.x, body.position.y

    love.graphics.draw(self.tex, px, py, 0, self.scale)
end

return comp