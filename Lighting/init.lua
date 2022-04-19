_Shaders = {}
_Shaders.light = love.graphics.newShader("Lighting/shaders/light.frag")
_Shaders.normal = love.graphics.newShader("Lighting/shaders/normal.frag")
_Shaders.blur = love.graphics.newShader("Lighting/shaders/blur.frag")

_Lighting = {}
_Lighting.lightWorld = require("Lighting.lightWorld")
_Lighting.light = require("Lighting.light")
_Lighting.occluder = require("Lighting.occluder")