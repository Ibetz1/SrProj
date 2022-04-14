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

_Res = {
    love.graphics.getWidth(),
    love.graphics.getHeight()
}

-- imports directory
local function importDir(path, sub, ignore)
    local content = love.filesystem.getDirectoryItems(path)
    local t = {}
    for _, c in pairs(content) do
        local name = c:gsub(sub, "")
        if string.match(c, sub) or ignore then
            t[name] = require(path .. "/" .. name)
        end
    end

    return t
end


-- import internals
_Util       = importDir(_UTILITYPATH, ".lua")
_Internal   = importDir(_INTERNALPATH, ".lua", true)
_Components = importDir(_COMPONENTPATH, ".lua")
_Lighting   = require(_LIGHTINGPATH)

-- import assets
_Assets = {}
local content = love.filesystem.getDirectoryItems(_IMAGEPATH)
for _, c in pairs(content) do
    if string.match(c, ".png") then _Assets[c:gsub(".png", "")] = love.graphics.newImage("assets/" .. c) end
    if string.match(c, ".jpg") then _Assets[c:gsub(".jpg", "")] = love.graphics.newImage("assets/" .. c) end
    if string.match(c, ".gif") then _Assets[c:gsub(".gif", "")] = love.graphics.newImage("assets/" .. c) end
end