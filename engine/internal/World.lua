local world = Object:new()

function world:init(w, h, d, ambience)
    self.w, self.h, self.d = w, h, d
    self.physicsGrid = Array3D(w, h, d)

    -- entity pointers
    self.entities = {}
    self.numEntities = 0

    for l = 1, d  do 
        self.entities[l] = {}
    end

    self.initialized = false

    -- rendering
    self.lightWorld = _Lighting.LightWorld(ambience or {0, 0, 0}, self.d)


    -- event handlers
    globalEventHandler:newEvent("staticCollision", function(id1, id2, dir) return {id1, id2, dir} end)
end

function world:onadd()
    for l = 1, self.d do
        for _, ent in pairs(self.entities[l]) do
            ent:onadd()
        end
    end

    self.initialized = true
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

    self.entities[layer][ent.id] = ent
    self.entities[ent.id] = layer
    ent.world = self
    ent.layer = layer
    ent.layerDepth = self.numEntities

    if self.initialized then ent:onadd() end
end

-- removes entity
function world:removeEntity(id)
    local layer = self.entities[id]
    
    if not layer then return end
    if not self.entities[layer][id] then return end

    self.entities[layer][id].remove = true
end

-- update world
function world:update(dt)

    -- update entities
    for l = 1, self.d do

        -- update entities
        for id, ent in pairs(self.entities[l]) do

            -- remove entity
            if ent.remove and not ent.removed then                
                ent:onremove()
                ent.removed = true
                self.entities[l][id] = nil
                self.entities[id] = nil

                goto next 
            end

            if ent.update then ent:update(dt) end

            ::next::
        end
    end

    self.lightWorld:update(dt)
end

-- draws world
function world:draw()
    self.lightWorld:draw()

    for l = 1, self.d do
        for id, ent in pairs(self.entities[l]) do

            if ent.draw then ent:draw(dt) end
    
            ::next::
        end
    end

end

-- shortcuts
function world:swapOccluders(b1, b2) self.lightWorld:swapBodies(b1, b2) end
function world:translate(x, y) self.lightWorld:setTranslation(x, y) end
function world:adjustScreenSize(w, h) self.lightWorld:setBuffers(w, h) end
function world:setScale(sx, sy) self.lightWorld:setScale(sx, sy) end
function world:convertScreenCoord(x, y) return self.lightWorld:translateScreenCoord(x, y) end
function world:scaleScreenCoord(x, y) return self.lightWorld:scaleScreenCoord(x, y) end

return world