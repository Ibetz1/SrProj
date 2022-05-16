local interface = Object:new()

function interface:init() 
    self.objects = {}

    self.eventExecutions = {
        mousepressed = {},
        mousereleased = {},
        keypressed = {},
        keyreleased = {}
    }
end

function interface:onadd()
    local function event(...) return {...} end

    for type, _ in pairs(self.eventExecutions) do
        love[type] = function(...)  globalEventHandler:push(type, ...) end
        globalEventHandler:newEvent(type, event)
    end

    for _, obj in pairs(self.objects) do
        if obj.onadd then obj:onadd() end
    end
end

-- make execution process for event
function interface:newEventInterface(type, index, val, f)
    if not self.eventExecutions[type] then return end

    self.eventExecutions[type][tostring(val)] = {f or function() end, index}
end

-- love2d keydown redefinition
function interface:keyDown(key)
    return love.keyboard.isDown(key)
end

-- love2d mousedown redefinition
function interface:mouseDown(b)
    return love.mouse.isDown(b)
end

-- checks if mouse is bound within a box
function interface:mouseBound(x, y, w, h)
    local mx, my = love.mouse.getPosition()
    return aabb(x, y, w, h, mx, my, 0, 0)
end 

function interface:update(dt)
    for name, executions in pairs(self.eventExecutions) do

        -- poll event and check executions
        for _, event in pairs(globalEventHandler:listen(name)) do

            -- call execution on event
            for val, exec in pairs(executions) do
                if event[exec[2]] == val then
                    exec[1]()
                end
            end
        end

    end

    for id, obj in pairs(self.objects) do
        if obj.remove and not obj.removed then
            if obj.onremove then obj:onremove() end
            obj.removed = true
            self.objects[id] = nil
            goto next
        end

        -- pass input events to object
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