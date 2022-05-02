local comp = _Util.Object:new({
    name = "controller",
    type = "objectController",
    embed = true,
    requires = {
        "physicsBody"    
    }
})

function comp:init(dx, dy, ww, wh)
    self.detected = {}
    self.dx = dx or 0
    self.dy = dy or 0
    self.wait = false
    self.ww, self.wh = ww or -1, wh or -1
end

function comp:update()
    local body = self.parent.Body

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