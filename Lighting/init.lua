_Shaders = {}
_Shaders.light = love.graphics.newShader("Lighting/shaders/light.glsl")

_Lighting = {}
_Lighting.lightWorld = require("Lighting.lightWorld")
_Lighting.light = require("Lighting.light")
_Lighting.occluder = require("Lighting.occluder")