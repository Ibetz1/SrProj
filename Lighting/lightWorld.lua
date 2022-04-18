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
    self.texBuffer =       love.graphics.newCanvas(w, h)
    self.lightingBuffer =  love.graphics.newCanvas(w, h)
    self.glowBuffer =      love.graphics.newCanvas(w, h)

    self.normalMap = love.graphics.newCanvas(w, h)
end

-- draws lights
function world:renderLights(dt)
    love.graphics.setCanvas(self.lightingBuffer)
        love.graphics.clear()
        love.graphics.origin()

        -- render each light
        for i = 1, #self.lights do
            local light = self.lights[i]

            light:update(dt, function()

                -- love.graphics.setBlendMode("subtract")

                for o = 1, #self.occluders do
                    local occluder = self.occluders[o]
                    local px, py = light.position:unpack()

                    -- render shadows and normals
                    if occluder:inRange(px, py, light.range) then

                        -- love.graphics.setBlendMode("subtract")

                        occluder:renderShadow(px, py, light.position.z, light.range, -px + light.range, -py + light.range)

                        love.graphics.setBlendMode("multiply", "premultiplied")

                        occluder:renderNormal(px, py, light.position.z, -px + light.range, -py + light.range)

                        love.graphics.setBlendMode("alpha")
                    end
                end

            end)

            love.graphics.setBlendMode("screen", "premultiplied")

            light:draw()

            love.graphics.setBlendMode("alpha")

        end
    love.graphics.setCanvas()
end

-- draw textures
function world:renderTextures()
    love.graphics.setCanvas(self.texBuffer)
    love.graphics.clear(1, 1, 1)

    for i = 1, #self.occluders do
        local occluder = self.occluders[i]

        occluder:drawTexture()
    end

    love.graphics.setCanvas()
end

function world:renderGlow()
end

-- updates world
function world:update(dt)
    self:renderLights()
    self:renderGlow()
    self:renderTextures()

    love.graphics.setCanvas(self.drawBuffer)

        love.graphics.origin()
        love.graphics.clear(unpack(self.ambience))

        -- stack buffers

        love.graphics.scale(self.scale.x, self.scale.y)

        love.graphics.setBlendMode("add")

        love.graphics.draw(self.lightingBuffer)

        love.graphics.setBlendMode("multiply", "premultiplied")

        love.graphics.draw(self.texBuffer)
    
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

    -- love.graphics.draw(self.shadowBuffer)


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

-- world occluders
function world:addOccluder(occluder)
    table.insert(self.occluders, occluder)
    occluder:setWorld(self)

    return #self.occluders
end

function world:removeOccluder(index) table.remove(self.occluders, index) end

return world