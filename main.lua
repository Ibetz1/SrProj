require("engine")
local game = require("game")

_World = game(16, 16, 2, {0.1, 0.1, 0.1})

_Screen.onFullScreen = function()
    if not _World then return end

    _World:adjustScreenSize()
    _World.lightWorld:centerBufferWindow()
end

love.window.setVSync(0)

local showstats = function()
    local stats = love.graphics.getStats( )

    love.graphics.print(love.timer.getFPS())

    love.graphics.print(collectgarbage("count"), 0, 12)
    love.graphics.print(tostring(stats.texturememory), 0, 24)
end

_Interface:newEventInterface("keypressed", 1, "f11", function() 
    _Screen:fullscreen()
end)

_Interface:newEventInterface("keypressed", 1, "left", function()
    if _Game.remainingRotations > 0 then 
        _EventManager:push("rotate", -1)
        _Game.remainingRotations = _Game.remainingRotations - 1
    end
end)

_Interface:newEventInterface("keypressed", 1, "right", function() 
    if _Game.remainingRotations > 0 then 
        _EventManager:push("rotate", 1)
        _Game.remainingRotations = _Game.remainingRotations - 1
    end
end)

_Interface:newEventInterface("keypressed", 1, "1", function()
    _Stack:loadInstance(function()
        _World = game(16, 16, 2, {0.1, 0.1, 0.1})

        game.constructors:lightDemo(_World, 13, 13)

        _Rendering.Pipeline:addLayer(showstats)
    end)
end)

_Interface:newEventInterface("keypressed", 1, "2", function()
    _Stack:loadInstance(function()
        _World = game(16, 16, 2, {0.1, 0.1, 0.1})

        game.constructors:gameWorld1(_World, 13, 13)

        _Rendering.Pipeline:addLayer(showstats)
    end)
end)