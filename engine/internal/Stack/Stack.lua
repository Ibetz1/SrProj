local stack = Object:new()

function stack:init()
    self.scenes = {}
end

-- clears the stack
function stack:clear()
    self.scenes = {}
end

function stack:loadInstance(func)
    self:clear()
    _Rendering.Pipeline:clear()

    func()
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

    if scene.draw then
        _Rendering.Pipeline:addLayer(scene.draw, scene)
    end

    scene:onadd()
end

-- updates current scene
function stack:update(dt)
    for _, scene in pairs(self.scenes) do
        if scene.update then scene:update(dt) end
    end
end

return stack