love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")
local stack, world, index = game(16, 16, 2, {0.2, 0.2, 0.25})

world:setScale(2, 2)

game.constructors:gameWorld1(world, 11, 11)

love.window.setVSync(0)

-- local b1 = game.entities:block(20, 10, 32, 24, 
--                               _Assets.machine,
--                               _Assets.machine_normal,
--                               _Assets.machine_glow, 0, 22)

-- local b2 = game.entities:wall(50, 50, 3, 1, 32, 24,                              
--                               _Assets.machine,
--                               _Assets.machine_normal,
--                               _Assets.machine_glow, 0, 22)
                

-- world:addEntity(b1)
-- world:addEntity(b2)

local light = _Lighting.Light(0, 0, 200, {1, 1, 1})
world.lightWorld:addLight(light)


function love.load()
end

function love.update(dt)
    local x, y = world:convertScreenCoord(love.mouse.getPosition())
    light:setPosition(x, y)

    stack:update(dt)
end

function love.draw()
    stack:draw()

    love.graphics.print(love.timer.getFPS())
end

function love.keypressed(key)
    if key == "space" then
        _Screen:fullscreen()
        world:adjustScreenSize()
    end
end