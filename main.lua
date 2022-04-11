love.graphics.setDefaultFilter("nearest", "nearest")
require("game")

local stack = _Internal.Stack()
local world = _Internal.World(20, 20, 1)
local worldSceneIndex = stack:addScene(world)


local e = _Internal.Entity()
e:addComponent(_Components.PhysicsBody(64, 64, 32, 32))
e:addComponent(_Components.PhysicsGridUpdater())
e:addComponent(_Components.RigidBody())

world:addEntity(e)

local f = _Internal.Entity()
f:addComponent(_Components.PhysicsBody(100, 64, 32, 32 ))
f:addComponent(_Components.PhysicsGridUpdater())
f:addComponent(_Components.RigidBody())

world:addEntity(f)

local g = _Internal.Entity()
g:addComponent(_Components.PhysicsBody(32, 32, 32, 32 ))
g:addComponent(_Components.PhysicsGridUpdater())
g:addComponent(_Components.RigidBody())

world:addEntity(g)

stack:setScene(worldSceneIndex)


function love.load()
end

function love.update(dt)
    if love.keyboard.isDown("w") then e.physicsBody:impulse(200, -1, "y") end
    if love.keyboard.isDown("a") then e.physicsBody:impulse(200, -1, "x") end
    if love.keyboard.isDown("s") then e.physicsBody:impulse(200, 1, "y") end
    if love.keyboard.isDown("d") then e.physicsBody:impulse(200, 1, "x") end

    stack:update(dt)
end

function love.draw()
    stack:draw()
end