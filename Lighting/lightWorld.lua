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

    self.normalBuffer = love.graphics.newCanvas(w, h)
    self.drawBuffer =      love.graphics.newCanvas(w, h)
    self.texBuffer =       love.graphics.newCanvas(w, h)
    self.lightingBuffer =  love.graphics.newCanvas(w, h)
    self.glowBuffer =      love.graphics.newCanvas(w, h)

    self.normalMap = love.graphics.newCanvas(w, h)
end

-- draws lights
function world:renderLights(dt)
    love.graphics.setCanvas(self.lightingBuffer)
        love.graphics.clear(0, 0, 0)
        love.graphics.origin()

        -- render each light
        for i = 1, #self.lights do
            local light = self.lights[i]

            -- render occlusion
            for o = 1, #self.occluders do
                local occluder = self.occluders[o]
                local px, py = light.position:unpack()

                -- update shadow buffer
                light:updateShadowBuffer(function()
                    if not occluder:inRange(px, py, light.range) then return end

                    occluder:renderShadow(px, py, light.position.z, light.range, -px + light.range, -py + light.range)

                end)

            end

            light:update(dt)

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

-- render normals
function world:renderNormals()
    love.graphics.setCanvas(self.normalMap)

    love.graphics.clear(1, 1, 1)

    -- iterate lights
    for l = 1, #self.lights do
        local light = self.lights[l]
        local px, py = light.position:unpack()

        -- render normals
        for i = 1, #self.occluders do
            local occluder = self.occluders[i]

            _ = (not occluder:inRange(px, py, light.range)) or occluder:renderNormal(px, py, light.range, 0, 0)
        end
    end

    love.graphics.setCanvas()
end

function world:renderGlow()
end

-- updates world
function world:update(dt)
    self:renderLights()
    self:renderNormals()
    self:renderGlow()
    self:renderTextures()

    love.graphics.setCanvas(self.drawBuffer)

        love.graphics.origin()
        love.graphics.clear(unpack(self.ambience))

        -- stack buffers

        love.graphics.scale(self.scale.x, self.scale.y)


        _Shaders.blur:send("Size", {self.lightingBuffer:getWidth(), self.lightingBuffer:getHeight()})

        love.graphics.setShader(_Shaders.blur)

        -- render lighting buffer
        love.graphics.setBlendMode("add")

        love.graphics.draw(self.lightingBuffer)
    
        love.graphics.setShader()

        -- render normals and textures
        love.graphics.setBlendMode("multiply", "premultiplied")
    
        love.graphics.draw(self.normalMap)
    
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