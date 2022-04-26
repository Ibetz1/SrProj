local comp = _Util.Object:new({
    name = "detector",
    type = "spacialDetector",
    embed = false,
    requires = {
        "physicsBody",
    }
})

function comp:init()
    self.detected = {}
end

function comp:update()
    local body = self.parent.Body

    if love.keyboard.isDown("w") then body:impulse(100, -1, "y") end
    if love.keyboard.isDown("a") then body:impulse(100, -1, "x") end
    if love.keyboard.isDown("s") then body:impulse(100, 1, "y") end
    if love.keyboard.isDown("d") then body:impulse(100, 1, "x") end
end

return comp