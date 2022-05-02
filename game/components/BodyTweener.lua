local comp = Object:new({
    embed = true,
    name = "Tweener",
    type = "tweening",
    requires = {
        "physicsBody"
    }
})

function comp:init()
    self.goal = Vector()
    self.tween = false
    self.dir = Vector()
end

function comp:onadd()
end

-- sets position of entity
function comp:tweenTo(x, y, dir)
    local body = self.parent.Body

    if not dir then body:setPosition(x, y); return end

    self.goal.x, self.goal.y = x, y
    self.dir.x, self.dir.y = dir.x, dir.y
    self.tween = true

    body.collideStatic = false
    body:setPosition(x - 2 * (body.w * dir.x), y - 2 * (body.h * dir.y))
end


-- update body
function comp:update(dt)

    local body = self.parent.Body

    body.collideStatic = not self.tween

    if self.parent.controller then self.parent.controller.wait = self.tween end

    if not self.tween then return end

    local dx, dy = self.goal.x - body.position.x, self.goal.y - body.position.y

    if math.abs(dx) > 1 then
        body:impulse(100, self.dir.x, "x")
    elseif math.abs(dy) > 1 then
        body:impulse(100, self.dir.y, "y")
    else
        self.tween = false
    end

end

function comp:draw()
end

return comp
