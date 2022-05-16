local button = Object:new()

function button:init(x, y, w, h, onhover, onpress, onrelease)
    self.hover = false
    self.press = false
    self.release = false
    self.position = Vector(x, y)
    self.w, self.h = w, h

    self.button = 1

    self.onhover = onhover or function() end
    self.onpress = onpress or function() end
    self.onrelease = onrelease or function() end
end

function button:update(dt)
    local mx, my = love.mouse.getPosition()

    self.hover = aabb(mx, my, 0, 0, self.position.x, self.position.y, self.w, self.init)


    
end

function button:draw()

    local mode = line
    if self.hover then mode = "fill" end

    love.graphics.rectangle(mode, self.position.x, self.position.y, self.w, self.h)

end