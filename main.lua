love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")
local stack, world, index = game(16, 16, 1)

-- love.window.setVSync(0)

local e = game.entities:block(100, 100, 32, 24, _Assets.machine)
local g = game.entities:block(100, 100, 32, 24, _Assets.machine)
local f = game.entities:block(100, 100, 32, 24, _Assets.machine)
local z = game.entities:block(100, 100, 32, 24, _Assets.machine)

world:addEntity(e)
world:addEntity(g)
world:addEntity(f)
world:addEntity(z)

world:setScale(2)

function love.load()
end

function love.update(dt)
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