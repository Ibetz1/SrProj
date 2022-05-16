require("engine")
local game = require("game")

local _Stack, _World, _Interface = game(16, 16, 2, {0.1, 0.3, 0.2})
game.constructors:gameWorld1(_World, 13, 13)

love.window.setVSync(0)

function love.load()
end

_Interface:newEventInterface("keypressed", 1, "f11", function() 
    _Screen:fullscreen()
    _World:adjustScreenSize()
    _World.lightWorld:center()
end)

_Interface:newEventInterface("keypressed", 1, "r", function()

end)

_Interface:newEventInterface("keypressed", 1, "left", function()
    if _Game.remainingRotations > 0 then 
        globalEventHandler:push("rotate", -1)
        _Game.remainingRotations = _Game.remainingRotations - 1
    end
end)

_Interface:newEventInterface("keypressed", 1, "right", function() 
    if _Game.remainingRotations > 0 then 
        globalEventHandler:push("rotate", 1)
        _Game.remainingRotations = _Game.remainingRotations - 1
    end
end)

function love.update(dt)
    _Stack:update(dt)
end

function love.draw()
    _Stack:draw()

    love.graphics.print(love.timer.getFPS())
end