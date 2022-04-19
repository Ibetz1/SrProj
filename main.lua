love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")
local stack, world, index = game(16, 16, 1)

love.window.setVSync(0)

require("Lighting")

local lw = _Lighting.lightWorld({0.1, 0.1, 0.1})
local light = _Lighting.light(100, 100, 200, {1, 0, 0})
local light1 = _Lighting.light(200, 200, 200, {0, 0.5, 1})
local occluder = _Lighting.occluder(200, 100, 32, 48)

lw:addLight(light)
lw:addLight(light1)
lw:addOccluder(occluder)

occluder:setTexture(_Assets.machine)
occluder:setNormal(_Assets.machine_normal)
occluder:setGlow(_Assets.machine_glow)

function love.load()
end

function love.update(dt)
    light:setPosition(love.mouse.getPosition())

    lw:update()
end

function love.draw()
    lw:draw()

    love.graphics.print(love.timer.getFPS())
    love.graphics.print(#lw.lights, 0, 12)
end
function love.mousepressed(x, y, b)
    if b == 1 then
        local light = _Lighting.light(x, y, 200, {0.5, 0.5, 1})
        lw:addLight(light)
    end
end