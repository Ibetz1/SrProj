local world = _Util.Object:new()

function world:init(w, h, d)
    self.w, self.h, self.d = w, h, d
    self.physicsGrid = _Util.Array3D(w, h, d)

    -- entity pointers
    self.entities = {}
    self.drawOrder = {}
    self.numEntities = 0
    for l = 1, d  do self.entities[l], self.drawOrder[l] = {}, {} end

    self.buffer = love.graphics.newCanvas(_Res[1], _Res[2])

    self.scale = 1
    self.currentScale = 1

    self.offset = _Util.Vector(0, 0)
    self.currentOffset = _Util.Vector(0, 0)

    -- settings
    self.offsetDiffuse = 1
    self.zoomDiffuse = 1

    self.initialized = false

    self.lightWorld = _Internal.Lighting({
        ambient = {1, 1, 1}
    })
end

function world:onadd()
    for l = 1, self.d do
        for _, ent in pairs(self.entities[l]) do
            ent:onadd()
        end
    end

    self.initialized = true
end

function world:setAmbience(r, g, b)
    self.lightWorld.ambient = {r, g, b}
end

-- scales world
function world:setScale(scale)
    self.scale = scale
    self.lightWorld:setScale(2)
end

-- creates a light
function world:newLight(x, y, z, r, g, b, range)
    local l = self.lightWorld:newLight(x, y, r, g, b, range)
    l:setPosition(x, y, z)
    return l
end

-- gets entity by id
function world:getEntity(id)
    local layer = self.entities[id]; if not layer then return end
    return self.entities[layer][id]
end

-- adds entity to world
function world:addEntity(ent, layer)
    self.numEntities = self.numEntities + 1
    local layer = layer or 1

    table.insert(self.drawOrder[layer], ent.id)
    
    self.entities[layer][ent.id] = ent
    self.entities[ent.id] = layer
    ent.world = self
    ent.layer = layer
    ent.layerDepth = self.numEntities
    ent.drawLayer = #self.drawOrder[layer]

    if self.initialized then ent:onadd() end
end

-- swaps draw order between two entities
function world:swapDrawOrder(ent1, ent2)
    local drawOrder = self.drawOrder[ent1.layer]
    drawOrder[ent1.drawLayer], drawOrder[ent2.drawLayer] = drawOrder[ent2.drawLayer], drawOrder[ent1.drawLayer]

    ent1.drawLayer, ent2.drawLayer = ent2.drawLayer, ent1.drawLayer
end

-- swaps occluder inceces in light world
function world:swapOccluders(occ1, occ2)
    local lw = self.lightWorld

    occ1.id, occ2.id = occ2.id, occ1.id

    lw.bodies[occ1.id], lw.bodies[occ2.id] = lw.bodies[occ2.id], lw.bodies[occ1.id]
end

-- removes entity
function world:removeEntity(id)
    local layer = self.entities[id]
    
    if not layer then return end
    if not self.entities[layer][id] then return end

    self.entities[layer][id].remove = true
end

-- translates world
function world:translate(x, y)
    self.offset.x, self.offset.y = x, y
end

-- update world
function world:update(dt)
    self.lightWorld:update(dt)

    -- update entities
    for l = 1, self.d do
        for id, ent in pairs(self.entities[l]) do

            if ent.remove then 
                ent:onremove()
                self.entities[l][id] = nil 
                self.entities[id] = nil
                goto next 
            end

            if ent.draw then ent:update(dt) end

            ::next::
        end
    end
end

-- draw world
function world:draw()
    self.lightWorld:draw(function() 
        love.graphics.clear(0.5, 0.5, 0.5)
        for l = 1, self.d do
            for _, id in pairs(self.drawOrder[l]) do
                local ent = self.entities[l][id]
                if ent.draw then ent:draw() end
            end
        end
    end)
end

return world