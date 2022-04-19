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
    self.resolutionScaling = 0.25

    -- apply settings
    for name, val in pairs(settings or {}) do
        self[name] = val   
    end 

    self:setBuffers()
end

-- sets buffers
function world:setBuffers(w, h)
    local w, h = w or love.graphics.getWidth(), h or love.graphics.getHeight()

    -- non resolution scales
    self.normalMap = love.graphics.newCanvas(w, h)
    self.texBuffer =       love.graphics.newCanvas(w, h)
    self.drawBuffer =      love.graphics.newCanvas(w, h)

    w, h = w * _Screen.ResolutionScaling, h * _Screen.ResolutionScaling

    -- resolution scaled
    self.lightingBuffer =  love.graphics.newCanvas(w, h)
    self.glowBuffer =      love.graphics.newCanvas(w, h)

end

-- draws lights
function world:renderLights(dt)
    love.graphics.setCanvas(self.lightingBuffer)
        love.graphics.clear(0, 0, 0)
        love.graphics.origin()

        -- render each light
        for i = 1, #self.lights do
            local light = self.lights[i]
            local px, py = light.position:unpack()
            local ox, oy = (-px + light.range) * _Screen.ResolutionScaling, (-py + light.range) * _Screen.ResolutionScaling

            -- render occlusion
            light:updateShadowBuffer(function(ox, oy)
                -- draw shadows
                for o = 1, #self.occluders do
                    local occluder = self.occluders[o]

                    -- update shadow buffer
                    if not occluder:inRange(px, py, light.range) then goto next end

                    occluder:renderShadow(px, py, light.position.z, light.range * _Screen.ResolutionScaling, ox, oy)

                    ::next::
                end

                -- clip shadows
                for o = 1, #self.occluders do
                    local occluder = self.occluders[o]

                    -- sub out occluder shape
                    if not occluder:inRange(px, py, light.range) then goto next end

                    -- set shadow clipping size
                    local w, h = occluder.w, occluder.h
                    if occluder.texture then
                        w, h = occluder.texture:getWidth(), occluder.texture:getHeight()
                    end

                    -- clip shadow
                    love.graphics.rectangle("fill", (occluder.position.x) * _Screen.ResolutionScaling + ox + 2, 
                                                    (occluder.position.y) * _Screen.ResolutionScaling + oy + 2, 
                                                    (w * _Screen.ResolutionScaling) - 2, (h * _Screen.ResolutionScaling) - 2)

                    ::next::
                end
            end, ox, oy)

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
    love.graphics.setCanvas(self.glowBuffer)

    for o = 1, #self.occluders do
        local occluder = self.occluders[o]

        occluder:renderGlow()
    end

    love.graphics.setCanvas()
end

-- updates world
function world:update(dt)
    self:renderTextures()
    self:renderLights()
    self:renderNormals()
    self:renderGlow()

    love.graphics.setCanvas(self.drawBuffer)

        love.graphics.origin()
        love.graphics.clear(unpack(self.ambience))

        -- stack buffers

        love.graphics.scale(self.scale.x, self.scale.y)

        -- render lighting buffer
        love.graphics.setBlendMode("add")

            love.graphics.scale(1 / _Screen.ResolutionScaling)

            love.graphics.draw(self.lightingBuffer)

            love.graphics.scale(_Screen.ResolutionScaling)

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
    -- love.graphics.scale(1 / self.resolutionScaling)
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