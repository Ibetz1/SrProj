love.graphics.setDefaultFilter("nearest", "nearest")
require("engine")


local lightWorld, lightMouse
local image, image_normal, glow, circleTest, rectangleTest, imageTest, objectTest
local scanLight, floatLight
local lightDirection = 0.0

local box_locations = {
  {200, 200},
  {600, 200},
  {600, 400},
  {200, 400},
}

function love.load()
  image = love.graphics.newImage("assets/machine.png")
  normal = love.graphics.newImage("assets/machine_normal.png")
  glow = love.graphics.newImage("assets/machine_glow.png")
  -- create light world
  lightWorld = _Internal.Lighting({ambient = {0.21,0.21,0.21}})
  -- create light
  lightMouse = lightWorld:newLight(0, 0, 1, 0.49, 1, 300)
  lightMouse:setGlowStrength(0.3)


  floatLight = lightWorld:newLight(100, 100, 0.49, 1, 1, 200)
  floatLight:setGlowStrength(0.3)

  -- create shadow bodys
  for i, v in ipairs(box_locations) do
    imageTest = lightWorld:newImage(image, v[1], v[2])
    imageTest:setNormalMap(normal)
    imageTest:setGlowMap(glow)
  end
end

function love.update(dt, x, y, scale)


  floatLight:setPosition(math.sin(-1*lightDirection)*200+400, 100)
  lightDirection = lightDirection + dt

  love.window.setTitle("Light vs. Shadow Engine (FPS:" .. love.timer.getFPS() .. ")")
  x, y, scale = x or 0, y or 0, scale or 1
  lightMouse:setPosition((love.mouse.getX() - x)/scale, (love.mouse.getY() - y)/scale)
  lightWorld:update(dt)
  lightWorld:setTranslation(x, y, scale)
end

function love.draw()
  lightWorld:draw(function()
    love.graphics.clear(1, 1, 1)
    love.graphics.setColor(1, 1, 1)
    for i, v in ipairs(box_locations) do
      love.graphics.draw(image, v[1] - image:getWidth() * 0.5, v[2] - image:getHeight() * 0.5)
    end
  end)
end