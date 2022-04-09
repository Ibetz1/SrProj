local entity = _Util.Object:new()

function entity:init()
    self.id = _Util.UUID()
    self.remove = false
    self.layer = 1
    self.world = nil
    self.components = {}
end

function entity:onadd()
    for compName, comp in pairs(self.components) do
        for _, name in pairs(comp.requires) do
            assert(self.components[name], compName .. " requires " .. name .. " to function")
        end

        comp:onadd()
    end
end

function entity:onremove()
    for _, comp in pairs(self.components) do
        comp:onremove()
    end
end

-- indexes component
function entity:indexComponent(name)
    return self.components[name]
end

-- gets component
function entity:getComponent(name)
    return self.components[name]
end

-- removes component
function entity:addComponent(comp, name)
    comp.parent = self

    self.components[comp.name or name] = comp
    if comp.embed then self[comp.name or name] = comp end
end

function entity:removeComponent(name)
    if not self.components[name] then return end
    self.components[name].remove = true
end

-- updates components
function entity:update(dt)
    for id, comp in pairs(self.components) do
        if comp.remove then 
            comp:onremove()
            self.components[id] = nil
            goto next 
        end
        if comp.update then comp:update(dt) end
        ::next::
    end
end

-- draws components
function entity:draw()
    for id, comp in pairs(self.components) do
        if comp.draw then comp:draw() end
    end
end

return entity