local entity = _Util.Object:new()

function entity:init()
    self.id = _Util.UUID()
    self.remove = false
    self.layer = 1
    self.world = nil
    self.components = {}
    self.containedComponents = {}
end

function entity:onadd()
    for compName, comp in pairs(self.components) do
        
        if not comp.requires then goto exclude end
        for _, include in pairs(comp.requires) do
            -- multiple inclusions
            if type(include) == "table" then
                local assertion = "requires "
                
                -- check for multiple inclusions
                for index, name in pairs(include) do
                    if self.containedComponents[name] then goto exit end
                    
                    if index == #include then
                        assertion = assertion .. name
                    else
                        assertion = assertion .. name .. " or "
                    end
                end

                assert(false, compName .. assertion)

                ::exit::

            -- single inclusion
            else
                assert(self.containedComponents[include], compName .. " requires " .. include)
            end
        end

        ::exclude::
        if not comp.exclude then goto add end
        for _, exclude in pairs(comp.exclude) do
            assert(not self.containedComponents[exclude], compName .. " cannot coexist with " .. exclude)
        end

        ::add::
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
    self.containedComponents[comp.type or name] = comp
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