love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")

local stack = _Internal.Stack()
local world = _Internal.World(20, 20, 1)
local worldSceneIndex = stack:addScene(world)


local e = _Internal.Entity()
e:addComponent(_Components.WorldBody(10, 10, 32, 32))
-- e:addComponent(_Components.Texture())


world:addEntity(e)

stack:setScene(worldSceneIndex)

function love.load()
end

function love.update(dt)
    if love.keyboard.isDown("w") then e.Body:move(0, -1) end
    if love.keyboard.isDown("a") then e.Body:move(-1, 0) end
    if love.keyboard.isDown("s") then e.Body:move(0, 1) end
    if love.keyboard.isDown("d") then e.Body:move(1, 0) end

    stack:update(dt)
end

function love.draw()
    stack:draw()
end