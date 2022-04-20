love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")
local stack, world, index = game(16, 16, 1)

love.window.setVSync(0)

local lw = _Lighting.LightWorld({0.3, 0.1, 0.2})
local light = _Lighting.Light(100, 100, 200, {0.5, 0.5, 0.5})

for i = 1, 5 do
    local x, y = 100 + i * 32, 100 + i * 48
    local occluder = _Lighting.Body(x, y, 32, 26, {
        offset = Vector(0, 20),
        -- occlude = false
    })
    occluder:setTexture(_Assets.machine)
    occluder:setNormal(_Assets.machine_normal)
    occluder:setGlow(_Assets.machine_glow)

    lw:addBody(occluder)
end

lw:setScale(1.5, 1.5)
lw:setTranslation(100, 0)
lw:addLight(light)



function love.load()
end

local theta = 0

function love.update(dt)

    theta = theta + 0.5
    if theta > 360 then
        theta = 0
    end

    light:setColor(HSV(theta, 1, 1))

    light:setPosition(love.mouse.getX() / lw.scale.x - 100, love.mouse.getY() / lw.scale.y)

    lw:update(dt)
end

function love.draw()
    lw:draw()

    love.graphics.print(love.timer.getFPS())
    love.graphics.print(#lw.lights, 0, 12)
end

function love.mousepressed(x, y, b)
    if b == 1 then
        local light = _Lighting.Light(x / lw.scale.x - 100, y / lw.scale.x, 200, {HSV(theta, 1, 1)})
        lw:addLight(light)
    end

    if b == 2 then
        love.window.setFullscreen(not love.window.getFullscreen())
    end
end