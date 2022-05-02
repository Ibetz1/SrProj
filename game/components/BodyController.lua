local comp = _Util.Object:new({
    name = "controller",
    type = "objectController",
    embed = true,
    requires = {
        "physicsBody",
        "tweening"
    }
})

function comp:init(dx, dy, ww, wh)
    self.detected = {}
    self.dx = dx or 0
    self.dy = dy or 0
    self.wait = false
    self.ww, self.wh = ww or -1, wh or -1
end

function comp:wrap(col)
    local dir = col[3]
    local body = self.parent.Body
    local gx, gy = body.position:unpack()

    if self.ww == -1 or self.wh == -1 then
        self.parent.Tweener:tweenTo(
           body.initialPosition:unpack()
        )

        return
    end

    if dir.x ~= 0 then
        if dir.x < 0 then gx = self.ww - 2 * _Constants.Tilesize end
        if dir.x > 0 then gx = _Constants.Tilesize end
    elseif dir.y ~= 0 then
        if dir.y < 0 then gy = self.wh - 2 * _Constants.Tilesize end
        if dir.y > 0 then gy = 2 * _Constants.Tilesize end
    end

    self.parent.Tweener:tweenTo(
        gx, gy, dir
    )
end

function comp:update()
    local body = self.parent.Body

    -- apply wrapping
    local collision = globalEventHandler:listen("staticCollision")

    for i = 1, #collision do
        local col = collision[i]
        _ = (col[1] ~= self.parent.id) or self:wrap(col)
    end

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