local eventHandler = _Util.Object:new()

function eventHandler:init()
    self.events = {}
end

-- creates an event
function eventHandler:newEvent(name, f)
    self.events[name] = {
        active = false,
        id = _Util.UUID(),
        f = f,
        params = {}
    }
end

-- toggles event with params
function eventHandler:toggle(name, ...)
    local e = self.events[name]
    e.active = true
    e.params = {...}
end

-- listens for event
function eventHandler:listen(name)
    if not self.events[name] then return end

    return self.events[name].active
end

-- checks for event toggles
function eventHandler:update(dt)
    for _, event in pairs(self.events) do
        if event.active then
            event.active = false

            if event.f then event.f(unpack(event.params)) end
            event.params = {}
        end
    end
end

return eventHandler