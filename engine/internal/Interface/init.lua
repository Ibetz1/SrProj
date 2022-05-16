local _PACKAGE = string.gsub(...,"%.","/") or ""
if string.len(_PACKAGE) > 0 then _PACKAGE = _PACKAGE .. "/" end

_Interface = {}
_Interface.Handler = require(_PACKAGE .. "Handler")
_Interface.Button = require(_PACKAGE .. "Button")