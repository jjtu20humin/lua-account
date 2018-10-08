--
local _M = { _VERSION = '0.08' }

local mt = { __index = _M }

function _M.new( db, openid )
    return setmetatable({ db = db, openid = openid }, mt)
end

function _M.go( self, pattern )
	local _replace = function ( s )
		if ( type( self[s] ) == "function" ) then
			return self[s]( self );
		end;
		return "";
	end;
	local _html_out = string.gsub( pattern, "<!%-%-LP_BEGIN%-%-## ([A-Z_]+) ##%-%-LP_END%-%->", _replace );
        return _html_out;
end;

return _M;
