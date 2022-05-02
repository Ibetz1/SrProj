local _PACKAGE = string.gsub(...,"%.","/") or ""
if string.len(_PACKAGE) > 0 then _PACKAGE = _PACKAGE .. "/" end

_IMAGEPATH          = _IMAGEPATH or "assets"
_SHADERPATH         = _SHADERPATH or "shaders"
_COMPONENTPATH      = _COMPONENTPATH or _PACKAGE .. "components"
_UTILITYPATH        = _UTILITYPATH or _PACKAGE .. "util"
_INTERNALPATH       = _INTERNALPATH or _PACKAGE .. "internal"
_LIGHTINGPATH       = _LIGHTINGPATH or _PACKAGE .. "lighting"


_Constants = {
    Friction = 0.8,
    Gravity = 100,
    Tilesize = 16
}

_Game = {}

-- imports directory
local function importDir(settings)
    local content = love.filesystem.getDirectoryItems(settings["path"])
    local t = {}
    for _, c in pairs(content) do
        local name = c:gsub(settings["sub"], "")
        if string.match(c, settings["sub"]) or settings["ignore"] then
            local dir = require(settings["path"] .. "/" .. name)
            t[name] = dir

            if settings["global"] then _G[name] = dir end
        end
    end

    return t
end


-- import internals
_Util       = importDir {path = _UTILITYPATH, sub = ".lua", global = true}
_Internal   = importDir {path = _INTERNALPATH, sub = ".lua", ignore = true}
_Components = importDir {path = _COMPONENTPATH, sub = ".lua", global = true}

_Screen = {
    love.graphics.getWidth(),
    love.graphics.getHeight(),
    aspectRatio = Vector(1, 1),
    smallScreenSize = Vector(love.graphics.getWidth(), love.graphics.getHeight()),
    fullScreenSize = Vector(),
    isfullscreen = false,
}

function _Screen:fullscreen()

    love.window.setFullscreen(not self.isfullscreen)

    self.isfullscreen = love.window.getFullscreen()

    self[1], self[2] = love.graphics.getWidth(), love.graphics.getHeight()

    -- size aspect ratio
    if self.isfullscreen then
        self.fullScreenSize.x = love.graphics.getWidth()
        self.fullScreenSize.y = love.graphics.getHeight()

        local aspect = math.min(self.fullScreenSize.x / self.smallScreenSize.x, self.fullScreenSize.y / self.smallScreenSize.y)

        self.aspectRatio.x, self.aspectRatio.y = aspect, aspect
    else
        self.aspectRatio.x, self.aspectRatio.y = 1, 1
    end
end


-- import assets
_Assets = {}
local content = love.filesystem.getDirectoryItems(_IMAGEPATH)
for _, c in pairs(content) do
    if string.match(c, ".png") then _Assets[c:gsub(".png", "")] = love.graphics.newImage("assets/" .. c) end
    if string.match(c, ".jpg") then _Assets[c:gsub(".jpg", "")] = love.graphics.newImage("assets/" .. c) end
    if string.match(c, ".gif") then _Assets[c:gsub(".gif", "")] = love.graphics.newImage("assets/" .. c) end
end

_Shaders = {}
local content = love.filesystem.getDirectoryItems(_SHADERPATH)
for _, c in pairs(content) do
    if string.match(c, ".frag") then _Shaders[c:gsub(".frag", "")] = love.graphics.newShader("shaders/" .. c) end
end