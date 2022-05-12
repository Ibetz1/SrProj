love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")

local _Stack, _World, _Interface = game(16, 16, 2, {1, 0, 0})
game.constructors:gameWorld1(_World, 13, 13)

love.window.setVSync(0)

function love.load()
end

function love.update(dt)
    _Stack:update(dt)
end

function love.draw()
    _Stack:draw()

    local press = globalEventHandler:listen("keypressed")

    -- if press[1] == 1 then
    --     _Screen:fullscreen()
    --     _World:adjustScreenSize()
    --     _World.lightWorld:center()
    -- end

    love.graphics.print(love.timer.getFPS())

end

-- controls
function love.keypressed(key)
    if key == "f11" then

    end

    if key == "r" then
        _Stack, _World, _Index = game(16, 16, 2, {0.3, 0.0, 0.3})
        game.constructors:gameWorld1(_World, 13, 13)
    end

    if key == "left" then
        if _Game.remainingRotations == 0 then return end
        globalEventHandler:push("rotate", -1)
        _Game.remainingRotations = _Game.remainingRotations - 1
    end

    if key == "right" then
        if _Game.remainingRotations == 0 then return end
        globalEventHandler:push("rotate", 1)
        _Game.remainingRotations = _Game.remainingRotations - 1
    end
end