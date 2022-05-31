local _PACKAGE = string.gsub(...,"%.","/") or ""
if string.len(_PACKAGE) > 0 then _PACKAGE = _PACKAGE .. "/" end

_Rendering = {}
_Rendering.Pipeline = require(_PACKAGE .. "pipeline")()


_Screen = {
    love.graphics.getWidth(),
    love.graphics.getHeight(),
    aspectRatio = Vector(1, 1),
    smallScreenSize = Vector(love.graphics.getWidth(), love.graphics.getHeight()),
    fullScreenSize = Vector(),
    isfullscreen = false,
}

_Screen.onFullScreen = function() end

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

    _Rendering.Pipeline:setBuffers()
    _Screen.onFullScreen()
end