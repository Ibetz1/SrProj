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

    scene:onadd()
end

-- updates current scene
function stack:update(dt)
    for _, scene in pairs(self.scenes) do
        if scene.update then scene:update(dt) end
    end

    self.eventHandler:update()
end

-- draws current scene
function stack:draw()
    for _, scene in pairs(self.scenes) do
        love.graphics.push()

            love.graphics.origin()

            love.graphics.scale(_Screen.aspectRatio.x, _Screen.aspectRatio.y) 

            if scene.draw then scene:draw() end

        love.graphics.pop()
    end
end

return stack