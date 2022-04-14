love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")
local game = require("game")
local stack, world, index = game(16, 16, 1)

-- local e = game.entities:block(100, 100, 32, 24, _Assets.machine)
-- local g = game.entities:block(100, 100, 32, 24, _Assets.machine)
-- local f = game.entities:block(100, 100, 32, 24, _Assets.machine)
-- local z = game.entities:block(100, 100, 32, 24, _Assets.machine)

-- world:addEntity(e)
-- world:addEntity(g)
-- world:addEntity(f)
-- world:addEntity(z)

-- world:setScale(2)

local lw = _Lighting.LightWorld:new()
lw:SetColor(255, 0, 0)

local body = _Lighting.Body:new(lw)


function love.load()
end

function love.update(dt)
    -- _ = not (love.keyboard.isDown("w")) or e.Body:impulse(100, -1, "y")
    -- _ = not (love.keyboard.isDown("a")) or e.Body:impulse(100, -1, "x")
    -- _ = not (love.keyboard.isDown("s")) or e.Body:impulse(100, 1, "y")
    -- _ = not (love.keyboard.isDown("d")) or e.Body:impulse(100, 1, "x")

    -- stack:update(dt)
    lw:Update()
end

function love.draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.rectangle("fill", 0, 0, love.graphics.getWidth(), love.graphics.getHeight())

    lw:Draw()
    -- stack:draw()
end