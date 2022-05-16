local _PACKAGE = string.gsub(...,"%.","/") or ""
if string.len(_PACKAGE) > 0 then _PACKAGE = _PACKAGE .. "/" end

_Internal.Stack = require(_PACKAGE .. "Stack")
_Internal.Scene = require(_PACKAGE .. "Scene")
_Internal.EventHandler = require(_PACKAGE .. "EventHandler")