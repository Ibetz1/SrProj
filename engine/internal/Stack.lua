local stack = Object:new()

function stack:init()
    self.scenes = {}
    self.scene = nil

    self.eventHandler = _Internal.EventHandler()
    _G.globalEventHandler = self.eventHandler
end

-- makes a new scene
function stack:newScene(...)
    local s = _Internal.Scene(...)
    table.insert(self.scenes, s)

    return s, #self.scenes
end

-- adds a pre-existing scene
function stack:addScene(scene)
    table.insert(self.scenes, scene)
    return #self.scenes
end

-- sets current scene
function stack:setScene(index)
    self.scene = index

    self.scenes[index]:onadd()
end

-- updates current scene
function stack:update(dt)
    if not self.scene then return end

    self.scenes[self.scene]:update(dt)

    self.eventHandler:update()
end

-- draws current scene
function stack:draw()
    if not self.scene then return end
    self.scenes[self.scene]:draw()
end

return stack