love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")
local stack, world, index = game(16, 16, 1)

love.window.setVSync(0)

require("Lighting")

local lw = _Lighting.lightWorld({0.2, 0.2, 0.2})
local light = _Lighting.light(100, 100, 200, {0.5, 0.5, 1})
local occluder = _Lighting.occluder(100, 100, 32, 32)
occluder:setTexture(_Assets.machine)

lw:addLight(light)
lw:addOccluder(occluder)

occluder:setTexture(_Assets.machine)
occluder:setNormal(_Assets.machine_normal)

function love.load()
end

function love.update(dt)
    light:setPosition(love.mouse.getPosition())

    lw:update()
end

function love.draw()
    lw:draw()

    love.graphics.print(love.timer.getFPS())
end