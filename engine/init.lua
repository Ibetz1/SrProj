local _PACKAGE = string.gsub(...,"%.","/") or ""
if string.len(_PACKAGE) > 0 then _PACKAGE = _PACKAGE .. "/" end

love.graphics.setDefaultFilter("nearest", "nearest")

-- imports directory
local function importDir(settings)
    local content = love.filesystem.getDirectoryItems(settings["path"])
    local t = _G[settings.insertion] or {}


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


_IMAGEPATH          = _IMAGEPATH or "assets"
_SHADERPATH         = _SHADERPATH or "shaders"
_COMPONENTPATH      = _COMPONENTPATH or _PACKAGE .. "components"
_UTILITYPATH        = _UTILITYPATH or _PACKAGE .. "util"
_INTERNALPATH       = _INTERNALPATH or _PACKAGE .. "internal"
_LIGHTINGPATH       = _LIGHTINGPATH or _PACKAGE .. "lighting"


_Constants = {
    Friction = 0.5,
    Tilesize = 16
}

-- define packages
_Game, _Shaders, _Assets, _Util, _Components, _Internal = {}, {}, {}, {}, {}, {}

-- import internals
importDir {path = _UTILITYPATH, sub = ".lua", global = true, insertion = "_Util"}
importDir {path = _COMPONENTPATH, sub = ".lua", global = true, insertion = "_Components"}
importDir {path = _INTERNALPATH, sub = ".lua", ignore = true, insertion = nil}


-- import assets
local content = love.filesystem.getDirectoryItems(_IMAGEPATH)
for _, c in pairs(content) do
    if string.match(c, ".png") then _Assets[c:gsub(".png", "")] = love.graphics.newImage("assets/" .. c) end
    if string.match(c, ".jpg") then _Assets[c:gsub(".jpg", "")] = love.graphics.newImage("assets/" .. c) end
    if string.match(c, ".gif") then _Assets[c:gsub(".gif", "")] = love.graphics.newImage("assets/" .. c) end
end

local content = love.filesystem.getDirectoryItems(_SHADERPATH)
for _, c in pairs(content) do
    if string.match(c, ".frag") then _Shaders[c:gsub(".frag", "")] = love.graphics.newShader("shaders/" .. c) end
end

-- initiate internals
_EventManager = _Internal.EventManager()
_Stack = _Internal.Stack()
_Interface = _UserInterface.Handler()

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

    _Stack.onadd()
    _Rendering.Pipeline:onadd()
    _Interface:onadd()
    _EventManager:onadd()

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
		if love.timer then dt = love.timer.step() end

		-- Call update and draw
		if love.update then love.update(dt) end -- will pass 0 if love.timer is disabled

        -- update engine internals
        _Interface:update(dt)
        _Stack:update(dt)
        _EventManager:update(dt)
        _Rendering.Pipeline:update(dt)

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

            _Rendering.Pipeline:draw()

			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end