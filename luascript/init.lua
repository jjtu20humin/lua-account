-- init module.
-- auther: qox
-- env setup.

package.path = package.path ..";/openresty/nginx/luascript/?.lua;/openresty/nginx/luascript/?/init.lua";

-- require modules .
---- system module
cjson = require "cjson";
cjson_safe = require "cjson.safe";
sstr = require "resty.string";
md5 = require "resty.md5";

require "global";
require "config";
require "interface";
require "info";
require "db";

function Do_LAPI()
    ngx.header["Content-type"] = "text/html;charset=utf-8";
    local _res = if_route();
    local _ret = "";
    if( type (_res ) == "table" ) then
        _ret = _JSON(_res) ;
    elseif( type( _res ) == "string" ) then
        _ret = _res ;
    end;
    ngx.header["Content-Length"] = #_ret;
    _SAY ( _ret );
end
