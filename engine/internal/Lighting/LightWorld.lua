local world = Object:new({
    resolutionScaling = 1
})

function world:init(ambience, d, settings)
    self.ambience = ambience or {1, 1, 1}
    self.d = d or 1


    self.lights = {}
    self.bodies = {}

    for i = 1, self.d do self.bodies[i] = {} end

    self.scale = Vector(1, 1)
    self.translation = Vector()
    self.offset = Vector()

    self.glowTick = 0
    self.glowDir = 1

    -- scaling methods
    self.checkRange = true

    -- apply settings
    for name, val in pairs(settings or {}) do
        self[name] = val   
    end 

    self:setBuffers()
end

-- sets buffers
function world:setBuffers(w, h)
    local bufferWindow = self.bufferWindow or {
        w or love.graphics.getWidth(), h or love.graphics.getHeight()
    }

    -- non resolution scaled buffers
    self.normalBuffer =    love.graphics.newCanvas(bufferWindow[1], bufferWindow[2])
    self.normalMap =       love.graphics.newCanvas(bufferWindow[1], bufferWindow[2])
    self.texBuffer =       love.graphics.newCanvas(bufferWindow[1], bufferWindow[2])
    self.drawBuffer =      love.graphics.newCanvas(bufferWindow[1], bufferWindow[2])
    self.glowBuffer =      love.graphics.newCanvas(bufferWindow[1], bufferWindow[2])

    -- resolution scaled buffers
    self.lightingBuffer =  love.graphics.newCanvas(w, h)

end

-- renders lighting buffer
function world:renderLights(dt)
    love.graphics.setCanvas(self.lightingBuffer)
        love.graphics.clear(0, 0, 0, 0)

        love.graphics.origin()
        local tx, ty = self.translation.x, self.translation.y

        -- render each light
        for i = 1, #self.lights do
            local light = self.lights[i]
            local px, py = light.position:unpack()

            local ox, oy = (-px + light.range), (-py + light.range)

            -- render occlusion
            light:updateShadowBuffer(function(ox, oy)
                -- draw shadows
                for l = 1, self.d do
                    for o = 1, #self.bodies[l] do
                        local body = self.bodies[l][o]

                        -- update shadow buffer
                        if not body or not body.occlude then goto next end
                        if not body:inRange(px, py, light.range) and self.checkRange then goto next end

                        body:renderShadow(px, py, light.range, ox, oy, -self.translation.x, -self.translation.y)
                        
                        ::next::
                    end

                    for o = 1, #self.bodies[l] do

                        local body = self.bodies[l][o]

                        if not body or not body.occlude then goto next end
                        if not body:inRange(px, py, light.range) and self.checkRange then goto next end

                        local w, h = body.w, body.h

                        if body.texture then w, h = body.texture:getWidth(), body.texture:getHeight()end

                        love.graphics.setColor(1, 1, 1, body.alpha)

                        love.graphics.rectangle("fill", body.position.x + ox, body.position.y + oy, w, h)

                        love.graphics.setColor(1, 1, 1, 1)

                        ::next::
                    end
                end

            end, tx, ty, ox, oy)

            light:update(dt, tx, ty)

            love.graphics.setBlendMode("screen", "premultiplied")

            love.graphics.translate(tx, ty)

            light:draw()

            love.graphics.origin()
        end

        love.graphics.setBlendMode("alpha")

    love.graphics.setCanvas()
end

-- normalizes lighrs
function world:normalizeLights()
    love.graphics.setCanvas(self.normalBuffer)
        love.graphics.clear(0, 0, 0)


        love.graphics.setBlendMode("add", "premultiplied")

        love.graphics.draw(self.normalMap)

        love.graphics.setBlendMode("multiply", "premultiplied")
 
        love.graphics.draw(self.lightingBuffer)

        love.graphics.setBlendMode("add", "premultiplied")

        love.graphics.draw(self.lightingBuffer)

        love.graphics.setBlendMode("alpha")

    love.graphics.setCanvas()
end

-- renders textures
function world:renderTextures()
    love.graphics.setCanvas(self.texBuffer)
    love.graphics.clear(1, 1, 1)
    love.graphics.origin()
    love.graphics.translate(self.translation.x, self.translation.y)

    love.graphics.setBlendMode("alpha")

    for l = 1, self.d do
        for i = 1, #self.bodies[l] do
            local body = self.bodies[l][i]

            if not body then goto next end
    
            body:renderTexture(self)

            ::next::
        end
    end


    love.graphics.setCanvas()
end

-- render normal map
function world:renderNormals()
    love.graphics.setCanvas(self.normalMap)
    love.graphics.clear(0,0,0)
    love.graphics.origin()
    love.graphics.translate(self.translation.x, self.translation.y)

        love.graphics.setBlendMode("add")

        love.graphics.setShader(_Shaders.normal)

        for l = 1, self.d do

            -- iterate lights
            for j = 1, #self.lights do
                local light = self.lights[j]
                local px, py = light.position:unpack()

                _Shaders.normal:send("LightPos", {px, py, light.position.z})

                -- render normals
                for i = 1, #self.bodies[l] do
                    local body = self.bodies[l][i]
        
                    if not body then goto next end

                    if (body:inRange(px, py, light.range)) or self.checkRange == false  then

                        body:renderNormal(px, py, 1, 0, 0)

                    end

                    ::next::
                end    
            end
        end

        love.graphics.setShader()

        love.graphics.setBlendMode("alpha")

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

    for l = 1, self.d do
        for o = 1, #self.bodies[l] do
            local body = self.bodies[l][o]

            if not body then goto next end
    
            body:renderGlow(self.glowTick)

            ::next::
        end
    end


    love.graphics.setCanvas()
end

-- updates world
function world:update(dt)
    self:renderTextures()
    self:renderLights()
    self:renderNormals()
    self:renderGlow(dt)
    self:normalizeLights()


    love.graphics.push()

    love.graphics.setCanvas(self.drawBuffer)
        love.graphics.origin()
        love.graphics.clear(unpack(self.ambience))

        love.graphics.scale(self.scale.x, self.scale.y)

        -- render lighting buffer
        love.graphics.setBlendMode("add")
        
            love.graphics.draw(self.normalBuffer)
        
        -- render normals and textures
        love.graphics.setBlendMode("multiply", "premultiplied")

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
    love.graphics.translate(self.offset.x, self.offset.y)
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

function world:center()
    local ox = (love.graphics.getWidth() - (self.drawBuffer:getWidth() * _Screen.aspectRatio.x)) / 2
    local oy = (love.graphics.getHeight() - (self.drawBuffer:getHeight() * _Screen.aspectRatio.y)) / 2

    self.offset.x, self.offset.y = ox, oy
end

function world:setOffset(x, y)
    self.offset.x = x or self.offset.x * self.scale.x
    self.offset.y = y or self.offset.y * self.scale.y
end

function world:getOffset()
    return self.offset
end

-- world lights
function world:addLight(light) 
    table.insert(self.lights, light)
    light:setWorld(self)

    return #self.lights 
end

function world:removeLight(index) table.remove(self.lights, index) end

-- adds world body
function world:addBody(body, index, l)
    local l = l or 1
    body.layer = l
    body.index = index or #self.bodies[l] + 1

    if index then
        self.bodies[l][index] = body
    else
        table.insert(self.bodies[l], body)
    end

    body:setWorld(self)

    return index or #self.bodies
end

-- swaps draw order for world bodies
function world:swapBodies(b1, b2)
    if b1.layer ~= b2.layer then return end

    self.bodies[b1.layer][b1.index], self.bodies[b2.layer][b2.index] = self.bodies[b2.layer][b2.index], self.bodies[b1.layer][b1.index]

    b1.index, b2.index = b2.index, b1.index
end

-- removes body
function world:removeBody(body) 
    -- self.bodies[body.layer][body.index] = nil
    if not body then return end

    self.bodies[body.layer][body.index] = nil
end

-- translates screen coord to scaled coord
function world:translateScreenCoord(x, y)
    local x = ((x - self.offset.x) / self.scale.x / _Screen.aspectRatio.x)
    local y = ((y - self.offset.y) / self.scale.y / _Screen.aspectRatio.y)

    return x , y
end

-- scales screen coord
function world:scaleScreenCoord(x, y)
    local x = x * self.scale.x * _Screen.aspectRatio.x
    local y = y * self.scale.y * _Screen.aspectRatio.y

    return x, y
end

-- sets buffer window
function world:setBufferWindow(w, h)
    self.bufferWindow = {
        w, h
    }

    self:setBuffers()
end

return world