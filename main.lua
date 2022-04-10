love.graphics.setDefaultFilter("nearest", "nearest")
require("modules")

local stack = _Internal.Stack()
local world = _Internal.World(20, 20, 1)
local worldSceneIndex = stack:addScene(world)

local e = _Internal.Entity()
e:addComponent(_Components.PhysicsBody(72, 16, 16, 16))
e:addComponent(_Components.WorldGridUpdater())
e:addComponent(_Components.RigidBody())

world:addEntity(e)


stack:setScene(worldSceneIndex)

function love.load()
end

function love.update(dt)
    if love.keyboard.isDown("w") then e.physicsBody:impulse(100, -1, "y") end
    if love.keyboard.isDown("s") then e.physicsBody:impulse(100, 1, "y") end
    if love.keyboard.isDown("a") then e.physicsBody:impulse(100, -1, "x") end
    if love.keyboard.isDown("d") then e.physicsBody:impulse(100, 1, "x") end

    stack:update(dt)
end

function love.draw()
    love.graphics.print(love.timer.getFPS())

    love.graphics.scale(2, 2)

    stack:draw()
end