local scene = _Util.Object:new()

function scene:init(...)
    self.layers = {...}
end

-- update layers
function scene:update(dt)
    for _, l in pairs(self.layers) do
        if l.update then l:update(dt) end
    end
end

-- draw layers
function scene:draw()
    for _, l in pairs(self.layers) do
        if l.draw then l:draw() end
    end
end

-- adds a layer
function scene:addLayer(obj)
    table.insert(self.layers, obj)

    return #self.layers
end

-- removes a layer
function scene:removeLayer(l)
    self.layers.remove(l)
end

return setmetatable(scene, scene)