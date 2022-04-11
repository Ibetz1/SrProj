local world = _Util.Object:new()

function world:init(w, h, d)
    self.w, self.h, self.d = w, h, d
    self.physicsGrid = _Util.Array3D(w, h, d)
    self.gridIndexDepth = 0

    -- entity pointers
    self.entities = {}
    for l = 1, d  do self.entities[l] = {} end

    self.buffer = love.graphics.newCanvas(_Res[1], _Res[2])

    self.scale = 1
    self.currentScale = 1

    self.offset = _Util.Vector(0, 0)
    self.currentOffset = _Util.Vector(0, 0)

    -- settings
    self.offsetDiffuse = 1
    self.zoomDiffuse = 1

    self.lightWorld = _Internal.Lighting({
        ambient = {0.21,0.21,0.21}
    })
end

function world:onadd()
    for l = 1, self.d do
        for _, ent in pairs(self.entities[l]) do
            ent:onadd()
        end
    end
end

-- gets entity by id
function world:getEntity(id)
    local layer = self.entities[id]; if not layer then return end
    return self.entities[layer][id]
end

-- adds entity to world
function world:addEntity(ent, layer)
    local layer = layer or 1
    self.gridIndexDepth = self.gridIndexDepth + 1

    self.entities[layer][ent.id] = ent
    self.entities[ent.id] = layer
    ent.world = self
    ent.layer = layer
    ent.gridIndex = self.gridIndexDepth
end

-- removes entity
function world:removeEntity(id)
    local layer = self.entities[id]
    
    if not layer then return end
    if not self.entities[layer][id] then return end

    self.entities[layer][id].remove = true
end

-- zooms world
function world:zoom(scale)
    self.scale = scale
end

-- translates world
function world:translate(x, y)
    self.offset.x, self.offset.y = x, y
end

-- pre render pass
function world:preRender()

end

-- update world
function world:update(dt)

    -- update all entities on layer
    for l = 1, self.d do
        -- update entities
        for id, ent in pairs(self.entities[l]) do
            if ent.remove then 
                ent:onremove()
                self.entities[l][id] = nil 
                self.entities[id] = nil
                goto next 
            end

            if ent.update then ent:update(dt) end
        end

        ::next::
    end
end

-- draw world
function world:draw()
    self:preRender()

    for l = 1, self.d do
        for _, ent in pairs(self.entities[l]) do
            if ent.draw then ent:draw() end
        end
    end
end

return world