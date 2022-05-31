local _PACKAGE = string.gsub(...,"%.","/") or ""
if string.len(_PACKAGE) > 0 then _PACKAGE = _PACKAGE .. "/" end

_UserInterface = {}
_UserInterface.Handler = require(_PACKAGE .. "Handler")