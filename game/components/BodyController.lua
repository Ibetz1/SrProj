local comp = _Util.Object:new({
    name = "detector",
    type = "spacialDetector",
    embed = false,
    requires = {
        "physicsBody",
        "tweening"
    }
})

function comp:init(dx, dy)
    self.detected = {}
    self.dx = dx or 0
    self.dy = dy or 0
end

function comp:update()
    local body = self.parent.Body

    if _Game.selected ~= self.parent.id then return end

    local dx, dy = 0, 0

    if love.keyboard.isDown("r") then
        local pos = body.initialPosition

        self.parent.Tweener:tweenTo(pos.x, pos.y)
    end

    if love.keyboard.isDown("space") then
        dx = self.dx
        dy = self.dy
    end

    body:impulse(100, dx, "x")
    body:impulse(100, dy, "y")
end

return comp