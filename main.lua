love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")

local stack, world, index = game(16, 16, 2, {0.2, 0.2, 0.2})
game.constructors:gameWorld1(world, 11, 11)

love.window.setVSync(0)

function love.load()
end

function love.update(dt)
    stack:update(dt)

end

function love.draw()
    stack:draw()

    love.graphics.print(love.timer.getFPS())
end

function love.keypressed(key)
    if key == "f11" then
        _Screen:fullscreen()
        world:adjustScreenSize()
        world.lightWorld:center()
    end

    if key == "r" then
        stack, world, index = game(16, 16, 2, {0.2, 0.2, 0.2})
        game.constructors:gameWorld1(world, 11, 11)
    end
end