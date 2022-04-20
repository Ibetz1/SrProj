local world = Object:new({
    resolutionScaling = 1
})

function world:init(ambience, settings)
    self.ambience = ambience or {1, 1, 1}


    self.lights = {}
    self.bodies = {}

    self.scale = Vector(1, 1)
    self.translation = Vector()

    self.glowTick = 0
    self.glowDir = 1

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
    
    w, h = w * _Screen.aspectRatio.x, h * _Screen.aspectRatio.y

    -- non resolution scales
    self.normalMap = love.graphics.newCanvas(w, h)
    self.texBuffer =       love.graphics.newCanvas(w, h)
    self.drawBuffer =      love.graphics.newCanvas(w, h)
    self.glowBuffer =      love.graphics.newCanvas(w, h)

    w, h = w * _Screen.ResolutionScaling, h * _Screen.ResolutionScaling

    -- resolution scaled
    self.lightingBuffer =  love.graphics.newCanvas(w, h)

end

-- renders lighting buffer
function world:renderLights(dt)
    love.graphics.setCanvas(self.lightingBuffer)
        love.graphics.clear(0, 0, 0)

        love.graphics.origin()
        local tx, ty = self.translation.x * _Screen.ResolutionScaling, self.translation.y * _Screen.ResolutionScaling

        -- love.graphics.translate(tx, ty)


        -- render each light
        for i = 1, #self.lights do
            local light = self.lights[i]
            local px, py = light.position:unpack()
            local ox, oy = (-px + light.range) * _Screen.ResolutionScaling, (-py + light.range) * _Screen.ResolutionScaling

            -- render occlusion
            light:updateShadowBuffer(function(ox, oy)
                -- draw shadows
                for o = 1, #self.bodies do
                    local body = self.bodies[o]

                    -- update shadow buffer
                    if not body:inRange(px, py, light.range) then goto next end

                    body:renderShadow(px, py, light.range * _Screen.ResolutionScaling, ox, oy, -self.translation.x, -self.translation.y)

                    ::next::
                end

                -- clip shadows
                for o = 1, #self.bodies do
                    local body = self.bodies[o]

                    -- sub out body shape
                    if not body:inRange(px, py, light.range) then goto next end

                    -- set shadow clipping size
                    local w, h = body.w, body.h
                    if body.texture then
                        w, h = body.texture:getWidth(), body.texture:getHeight()
                    end

                    local off = 2 * _Screen.ResolutionScaling

                    -- clip shadow
                    love.graphics.rectangle("fill", (body.position.x) * _Screen.ResolutionScaling + ox + off / 2, 
                                                    (body.position.y) * _Screen.ResolutionScaling + oy + off / 2, 
                                                    (w * _Screen.ResolutionScaling) - off, (h * _Screen.ResolutionScaling) - off)

                    ::next::
                end
            end, tx, ty, ox, oy)

            light:update(dt, tx, ty)

            love.graphics.setBlendMode("screen", "premultiplied")

            love.graphics.translate(tx, ty)

            light:draw()

            love.graphics.setBlendMode("alpha")

            love.graphics.origin()
        end

    love.graphics.setCanvas()
end

-- renders textures
function world:renderTextures()
    love.graphics.setCanvas(self.texBuffer)
    love.graphics.clear(1, 1, 1)
    love.graphics.origin()
    love.graphics.translate(self.translation.x, self.translation.y)

    for i = 1, #self.bodies do
        local body = self.bodies[i]

        body:renderTexture()
    end

    love.graphics.setCanvas()
end

-- render normal map
function world:renderNormals()
    love.graphics.setCanvas(self.normalMap)
    love.graphics.clear(1, 1, 1)
    love.graphics.origin()
    love.graphics.translate(self.translation.x, self.translation.y)

    -- iterate lights
    for l = 1, #self.lights do
        local light = self.lights[l]
        local px, py = light.position:unpack()

        -- render normals
        for i = 1, #self.bodies do
            local body = self.bodies[i]

            _ = (not body:inRange(px, py, light.range)) or body:renderNormal(px, py, light.range, 0, 0)

        end
    end

    love.graphics.setCanvas()
end

-- renders glow map
function world:renderGlow(dt)
    self.glowTick = self.glowTick + dt * self.glowDir
    if self.glowTick > 1 or self.glowTick < 0 then self.glowDir = -self.glowDir end

    self.glowTick = math.min(math.max(self.glowTick, 0), 1)

    love.graphics.setCanvas(self.glowBuffer)
    love.graphics.clear()
    love.graphics.origin()
    love.graphics.translate(self.translation.x, self.translation.y)

    for o = 1, #self.bodies do
        local body = self.bodies[o]

        body:renderGlow(self.glowTick)
    end

    love.graphics.setCanvas()
end

-- updates world
function world:update(dt)
    self:renderTextures()
    self:renderLights()
    self:renderNormals()
    self:renderGlow(dt)

    love.graphics.push()

    love.graphics.setCanvas(self.drawBuffer)
        love.graphics.origin()
        love.graphics.clear(unpack(self.ambience))

        -- render lighting buffer
        love.graphics.setBlendMode("add")

            love.graphics.scale((1 / _Screen.ResolutionScaling * self.scale.x), (1 / _Screen.ResolutionScaling * self.scale.y))

            love.graphics.draw(self.lightingBuffer)

            love.graphics.scale(_Screen.ResolutionScaling, _Screen.ResolutionScaling)


        -- render normals and textures
        love.graphics.setBlendMode("multiply", "premultiplied")
    
            love.graphics.draw(self.normalMap)
            
            love.graphics.draw(self.texBuffer)
    
        love.graphics.setBlendMode("add")

            love.graphics.draw(self.glowBuffer)

        love.graphics.setBlendMode("alpha")

    love.graphics.setCanvas()

    love.graphics.pop()

    love.graphics.scale(1, 1)

end

-- draws world
function world:draw()
    love.graphics.push()
    love.graphics.origin()

    -- scale
    -- love.graphics.translate(_Screen.aspectTranslation:unpack())
    love.graphics.scale(_Screen.aspectRatio.x, _Screen.aspectRatio.y) 

    love.graphics.draw(self.drawBuffer)

    love.graphics.pop()
end


-- world scale
function world:setScale(x, y) 
    self.scale.x, self.scale.y = x or 1, y or 1 
    self:setBuffers()
end

function world:getScale() return self.scale end

-- world translation

function world:setTranslation(x, y)
    self.translation.x = x or self.translation.x
    self.translation.y = y or self.translation.y
end

function world:getTranslation()
    return self.translation
end

-- world lights
function world:addLight(light) 
    table.insert(self.lights, light)
    light:setWorld(self)

    return #self.lights 
end

function world:removeLight(index) table.remove(self.lights, index) end

-- world bodys
function world:addBody(body)
    table.insert(self.bodies, body)
    body:setWorld(self)

    return #self.bodies
end

function world:removeBody(index) table.remove(self.bodies, index) end

-- translates screen coord to scaled coord
function world:translateScreenCoord(x, y)
    local x = (x / self.scale.x / _Screen.aspectRatio.x) - self.translation.x
    local y = (y / self.scale.x / _Screen.aspectRatio.y) - self.translation.y

    return x , y
end

return world