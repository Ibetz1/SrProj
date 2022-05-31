local comp = _Util.Object:new({
    name = "controller",
    type = "objectController",
    embed = true,
    requires = {
        "physicsBody",
        "texture"
    }
})

local dirs = {
    {1, 0},
    {0, 1},
    {-1, 0}, 
    {0, -1}
}

function comp:init(dx, dy, ww, wh)
    self.detected = {}
    self.dx = dx or 0
    self.dy = dy or 0
    self.wait = false
    self.ww, self.wh = ww or -1, wh or -1
end

function comp:rotate(dir)
    if self.parent.texture then
        local tex = self.parent.texture

        local index = wrap(tex.imageIndex + dir, 1, 4)
        tex.imageIndex = index

        if tex.body.texture then
            local tx = _Textures.player[index].Tex
            _ = tex.setImage
            tex:setImage(tx)
        end

        if tex.body.normal then
            local nm = _Textures.player[index].Norm
            tex:setNormalMap(nm)
        end

        self.dx = dirs[index][1]
        self.dy = dirs[index][2]
 
    end


end

function comp:update()
    local body = self.parent.Body

    -- rotate
    local dir = _EventManager:poll("rotate", 1)
    if dir then self:rotate(dir) end

    -- apply controls
    if _Game.selected ~= self.parent.id then return end
    if self.wait then return end

    local dx, dy = 0, 0

    if love.keyboard.isDown("space") then
        dx = self.dx
        dy = self.dy
    end

    body:impulse(100, dx, "x")
    body:impulse(100, dy, "y")
end

return comp