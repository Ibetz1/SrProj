local eventHandler = Object:new()

function eventHandler:init()
    self.events = {}

    self.activeEvents = {}
end

function eventHandler:clear()
    self.events = {}
end

-- creates an event
function eventHandler:newEvent(name, f)
    self.events[name] = {
        f = f or function() return true end
    }

    self.activeEvents[name] = {}
end

-- pushs event with params
function eventHandler:push(name, ...)
    local event = self.events[name]

    table.insert(self.activeEvents[name], event.f(...))
end

-- listens for event
function eventHandler:listen(name)
    return self.activeEvents[name]
end

-- reads event for value
function eventHandler:poll(name, index)
    return self:listen(name)[index]
end

-- clears specified event
function eventHandler:clearEvent(name)
    local event = self.activeEvents[name]

    if not event then return end

    while #event > 0 do
        table.remove(event, 1)
    end
end

-- clears all events
function eventHandler:update(dt)
    for name, _ in pairs(self.activeEvents) do
        self:clearEvent(name)
    end
end

return eventHandler