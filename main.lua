love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")
local stack, world, index = game(16, 16, 2, {0.12, 0.12, 0.12})

love.window.setVSync(1)

local e = game.entities:block(100, 100, 32, 24, _Assets.machine, _Assets.machine_normal, _Assets.machine_glow)
local g = game.entities:block(100, 100, 32, 24, _Assets.machine, _Assets.machine_normal, _Assets.machine_glow)
local f = game.entities:block(100, 100, 32, 24, _Assets.machine, _Assets.machine_normal, _Assets.machine_glow)
local z = game.entities:block(100, 100, 32, 24, _Assets.machine, _Assets.machine_normal, _Assets.machine_glow)

local light = game.entities:light(0, 0, 1, 200, 0, 200, 200, 1)

world:addEntity(e, 1)
world:addEntity(g)
world:addEntity(f)
world:addEntity(z)
world:setScale(2)

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

    love.graphics.print(love.timer.getFPS())
end