local world = Object:new({
    resolutionScaling = 1
})

function world:init(ambience, settings)
    self.ambience = ambience or {1, 1, 1}


    self.lights = {}
    self.occluders = {}

    self.scale = Vector(1, 1)
    self.translation = Vector()

    -- scaling methods
    self.resolutionScaling = 1

    -- apply settings
    for name, val in pairs(settings or {}) do
        self[name] = val   
    end 

    self:setBuffers()
end

-- sets buffers
function world:setBuffers(w, h)
    local w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()
    w, h = w * self.resolutionScaling, h * self.resolutionScaling


    self.drawBuffer =      love.graphics.newCanvas(w, h)
    self.lightingBuffer =  love.graphics.newCanvas(w, h)
    self.shadowBuffer =    love.graphics.newCanvas(w, h)
    self.normalBuffer =    love.graphics.newCanvas(w, h)
    self.glowBuffer =      love.graphics.newCanvas(w, h)
end

-- draws lights
function world:renderLights(dt)
    love.graphics.setCanvas(self.lightingBuffer)
        love.graphics.clear()
        love.graphics.origin()

        -- render each light
        for i = 1, #self.lights do
            self.lights[i]:update(dt)
            self.lights[i]:draw()
        end
        
    love.graphics.setCanvas()
end

function world:renderShadows()

end

function world:renderNormals()

end

function world:renderGlow()
end

-- updates world
function world:update(dt)
    self:renderLights()
    self:renderShadows()
    self:renderNormals()
    self:renderGlow()

    love.graphics.setCanvas({self.drawBuffer, stencil = true})

        love.graphics.clear(unpack(self.ambience))
        love.graphics.origin()

        -- stack buffers

        love.graphics.scale(self.scale.x, self.scale.y)

        love.graphics.setBlendMode("add")

        love.graphics.draw(self.lightingBuffer)

        love.graphics.setBlendMode("alpha")

    love.graphics.setCanvas()

end

-- draws world
function world:draw()
    love.graphics.push()
    love.graphics.origin()

    -- scale
    love.graphics.scale(1 / self.resolutionScaling)
    love.graphics.translate(self.translation:unpack())

    love.graphics.draw(self.drawBuffer)

    love.graphics.pop()
end


-- world scale
function world:setScale(x, y) self.scale.x, self.scale.y = x, y end
function world:getScale() return self.scale end

-- world lights
function world:addLight(light) 
    table.insert(self.lights, light)
    light:setWorld(self)

    return #self.lights 
end

function world:removeLight(index) table.remove(self.lights, index) end

return world