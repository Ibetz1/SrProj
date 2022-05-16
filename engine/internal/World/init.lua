local _PACKAGE = string.gsub(...,"%.","/") or ""
if string.len(_PACKAGE) > 0 then _PACKAGE = _PACKAGE .. "/" end

_Internal.World = require(_PACKAGE .. "World")
_Internal.Entity = require(_PACKAGE .. "Entity")
