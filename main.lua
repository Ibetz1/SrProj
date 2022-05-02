love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")

local _Stack, _World, _Index = game(16, 16, 2, {0.2, 0.2, 0.2})
game.constructors:gameWorld1(_World, 11, 11)

love.window.setVSync(0)

function love.load()
end

function love.update(dt)
    _Stack:update(dt)

    print(_Game.remainingRotations)
end

function love.draw()
    _Stack:draw()

    love.graphics.print(love.timer.getFPS())
end

-- controls
function love.keypressed(key)
    if key == "f11" then
        _Screen:fullscreen()
        world:adjustScreenSize()
        world.lightWorld:center()
    end

    if key == "r" then
        _Stack, _World, _Index = game(16, 16, 2, {0.2, 0.2, 0.2})
        game.constructors:gameWorld1(_World, 11, 11)
    end

    if key == "left" then
        if _Game.remainingRotations == 0 then return end
        globalEventHandler:toggle("rotate", -1)
        _Game.remainingRotations = _Game.remainingRotations - 1
    end

    if key == "right" then
        if _Game.remainingRotations == 0 then return end
        globalEventHandler:toggle("rotate", 1)
        _Game.remainingRotations = _Game.remainingRotations - 1
    end
end