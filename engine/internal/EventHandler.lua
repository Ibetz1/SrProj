local eventHandler = Object:new()

function eventHandler:init()
    self.events = {}

    self.activeEvents = {}
end

-- creates an event
function eventHandler:newEvent(name, f)
    self.events[name] = {
        f = f or function() return true end,
        alive = 0
    }

    self.activeEvents[name] = {}
end

-- toggles event with params
function eventHandler:toggle(name, ...)
    local event = self.events[name]

    table.insert(self.activeEvents[name], event.f(...))
end

-- listens for event
function eventHandler:listen(name)
    return self.activeEvents[name]
end

-- checks for event toggles
function eventHandler:update(dt)
    for _, event in pairs(self.activeEvents) do
        for i = 1, #event do
            table.remove(event, i)
        end
    end
end

return eventHandler