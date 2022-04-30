local comp = Object:new({
    embed = true,
    name = "Tweener",
    type = "tweening",
    requires = {
        {"worldBody", "physicsBody"}
    }
})

function comp:init(rate)
    self.goal = Vector()
    self.tween = false
    self.rate = rate or 0.1
end

function comp:onadd()
end

-- sets position of entity
function comp:tweenTo(x, y)

    self.goal.x, self.goal.y = x, y
    self.tween = true

end


-- update body
function comp:update(dt)
    if not self.tween then return end

    -- enter tweening
    local body = self.parent.Body
    local pos = body.position

    body.lock = true
    body.clip = false

    local dx, dy = self.goal.x - (pos.x), self.goal.y - (pos.y)

    -- exit tweening
    if math.abs(self.goal.x - pos.x) < 1 and math.abs(self.goal.y - pos.y) < 1 then
        self.tween = false
        body.lock = false
        body.clip = true
    end

    body:setPosition(pos.x + dx * self.rate, pos.y + dy * self.rate)

end

function comp:draw()
end

return comp
