-- define class module
local object = {}
object.__index = object

-- function for instancing
function object:init() end
function object:update() end
function object:draw() end
function object:onadd() end
function object:onremove() end

-- derives a new class
function object:new(cls)
    local cls = cls or {}

    cls.__index = cls

    return setmetatable(cls, self)
end

-- makes a new instance of class
function object:__call(...)
    local inst = setmetatable({}, self)

    inst:init(...)

    return inst
end

return object