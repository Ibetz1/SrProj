love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")

local stack = _Internal.Stack()
local world = _Internal.World(30, 30, 1)
local worldSceneIndex = stack:addScene(world)

world:setAmbience(0.12, 0.12, 0.12)

local e = _Internal.Entity()
e:addComponent(_Components.Ysort())
e:addComponent(_Components.PhysicsBody(10, 10, 32, 32))
e:addComponent(_Components.RigidBody())
e:addComponent(_Components.PhysicsGridUpdater())
e:addComponent(_Components.Texture(_Assets.machine, _Assets.machine_normal, _Assets.machine_glow), 4)
e:addComponent(_Components.Occluder())

world:addEntity(e)

local g = _Internal.Entity()
g:addComponent(_Components.Ysort())
g:addComponent(_Components.PhysicsBody(70, 40, 32, 20))
g:addComponent(_Components.RigidBody())
g:addComponent(_Components.PhysicsGridUpdater())
g:addComponent(_Components.Texture(_Assets.machine, _Assets.machine_normal, _Assets.machine_glow), 4)
g:addComponent(_Components.Occluder())

world:addEntity(g)

stack:setScene(worldSceneIndex)

world:setScale(2)

local light = world.lightWorld:newLight(0, 0, 100, 100, 100, 200)
light:setSmooth(1)

function love.load()
end


function love.update(dt)
    light:setPosition(love.mouse.getX() / world.scale, love.mouse.getY() / world.scale, 1)

    if love.keyboard.isDown("w") then e.Body:impulse(100, -1, "y") end
    if love.keyboard.isDown("a") then e.Body:impulse(100, -1, "x") end
    if love.keyboard.isDown("s") then e.Body:impulse(100, 1, "y") end
    if love.keyboard.isDown("d") then e.Body:impulse(100, 1, "x") end

    stack:update(dt)
end

function love.draw()
    stack:draw()
end