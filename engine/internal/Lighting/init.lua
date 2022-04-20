local _PACKAGE = string.gsub(...,"%.","/") or ""
if string.len(_PACKAGE) > 0 then _PACKAGE = _PACKAGE .. "/" end

_Lighting = {}
_Lighting.LightWorld = require(_PACKAGE .. "LightWorld")
_Lighting.Light = require(_PACKAGE .. "Light")
_Lighting.Body = require(_PACKAGE .. "Body")