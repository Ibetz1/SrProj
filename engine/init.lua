local _PACKAGE = string.gsub(...,"%.","/") or ""
if string.len(_PACKAGE) > 0 then _PACKAGE = _PACKAGE .. "/" end

_IMAGEPATH          = _IMAGEPATH or "assets"
_COMPONENTPATH      = _COMPONENTPATH or _PACKAGE .. "components"
_UTILITYPATH        = _UTILITYPATH or _PACKAGE .. "util"
_INTERNALPATH       = _INTERNALPATH or _PACKAGE .. "internal"
_LIGHTINGPATH       = _LIGHTINGPATH or _PACKAGE .. "lighting"


_Constants = {
    Friction = 0.8,
    Gravity = 100,
    Tilesize = 16
}

_Screen = {
    love.graphics.getWidth(),
    love.graphics.getHeight(),
    ResolutionScaling = 0.25
}

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


-- import assets
_Assets = {}
local content = love.filesystem.getDirectoryItems(_IMAGEPATH)
for _, c in pairs(content) do
    if string.match(c, ".png") then _Assets[c:gsub(".png", "")] = love.graphics.newImage("assets/" .. c) end
    if string.match(c, ".jpg") then _Assets[c:gsub(".jpg", "")] = love.graphics.newImage("assets/" .. c) end
    if string.match(c, ".gif") then _Assets[c:gsub(".gif", "")] = love.graphics.newImage("assets/" .. c) end
end