love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")
local stack, world, index = game(16, 16, 1)

love.window.setVSync(0)

require("Lighting")

local lw = _Lighting.lightWorld({0.1, 0.1, 0.2})
local light = _Lighting.light(100, 100, 200, {0.5, 0.5, 0.5})

for i = 1, 5 do
    local x, y = 100 + i * 32, 100 + i * 48
    local occluder = _Lighting.occluder(x, y, 32, 26, {
        offset = Vector(0, 20)
    })
    occluder:setTexture(_Assets.machine)
    occluder:setNormal(_Assets.machine_normal)
    occluder:setGlow(_Assets.machine_glow)

    lw:addOccluder(occluder)
end

lw:addLight(light)



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