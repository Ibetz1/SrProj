local interface = Object:new()

function interface:init() 
    self.objects = {}
end

function interface:onadd()

    local function event(...) return {...} end

    function love.mousepressed(...) globalEventHandler:push("mousepressed", ...) end
    function love.mousereleased(...) globalEventHandler:push("mousereleased", ...) end
    function love.keyreleased(...) globalEventHandler:push("keyreleased", ...) end
    function love.keypressed(...) globalEventHandler:push("keypressed", ...) end

    globalEventHandler:newEvent("mousepressed",  event)
    globalEventHandler:newEvent("keypressed",    event)
    globalEventHandler:newEvent("mousereleased", event)
    globalEventHandler:newEvent("keyreleased",   event)

    for id, obj in pairs(self.objects) do
        if obj.onadd then obj:onadd() end
    end
end

function interface:update(dt) 
    for id, obj in pairs(self.objects) do
        if obj.remove and not obj.removed then
            if obj.onremove then obj:onremove() end
            obj.removed = true
            self.objects[id] = nil
            goto next
        end

        obj:update(dt)

        ::next::
    end
end

function interface:draw() 
    for _, obj in pairs(self.objects) do
        obj:draw()
    end
end

function interface:addObject(obj)
    table.insert(self.objects, obj)
end

return interface