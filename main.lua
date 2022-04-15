love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")
local stack, world, index = game(16, 16, 1)

require("Lighting")

local lw = _Lighting.lightWorld({0.5, 0.5, 0.5})
local light = _Lighting.light(100, 100, 200, {0.5, 0.5, 1})
local occluder = _Lighting.occluder(100, 100, 32, 32)
occluder:setTexture(_Assets.machine)

print(tostring(light.position))

lw:addLight(light)

function love.load()
end

function love.update(dt)
    light:setPosition(love.mouse.getPosition())

    lw:update()
end

function love.draw()
    lw:draw()

    love.graphics.rectangle("fill", occluder.position.x, occluder.position.y, occluder.w, occluder.h)
    occluder:renderShadow(light.position.x, light.position.y, 300)
end