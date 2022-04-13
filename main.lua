love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")
local stack, world, index = game(16, 16, 1, {0.12, 0.12, 0.12})

local e = game.entities:block(100, 100, 32, 24, _Assets.machine, _Assets.machine_normal, _Assets.machine_glow)
local g = game.entities:block(100, 100, 32, 24, _Assets.machine, _Assets.machine_normal, _Assets.machine_glow)
local f = game.entities:block(100, 100, 32, 24, _Assets.machine, _Assets.machine_normal, _Assets.machine_glow)
local z = game.entities:block(100, 100, 32, 24, _Assets.machine, _Assets.machine_normal, _Assets.machine_glow)

world:addEntity(e)
world:addEntity(g)
world:addEntity(f)
world:addEntity(z)

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
    -- love.graphics.print(love.timer.getFPS())
end

function love.keyreleased(k)
    if k == "f11" then
        local fullscreen = love.window.getFullscreen()

        local w1, h1 = love.graphics.getWidth(), love.graphics.getHeight()

        love.window.setFullscreen(not fullscreen)

        local w2, h2 = love.graphics.getWidth(), love.graphics.getHeight()

        local aspect = w2 / w1

        if aspect > 1 then
            world:setAspect(aspect)
        else
            world:setAspect(0)
        end

        world:setScale()
        world:adjustScreenSize()
    end
end