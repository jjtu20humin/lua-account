-- auth

GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "获取应用包授权信息",
	desc = "获取应用包授权信息", 
	base_param = {
		{ name = "app_id",pattern = ".+", length = {1,}, helper = {"客户id","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","md5hex"}	},
	},

	opt_param = {
	},
};


GV_IFS[_module_]['callback'] = function(_REQ, _FILE )
	local _app_id = _REQ["app_id"];

	local _rcode, _res = app_get_auth( _app_id );
	if _rcode < 0 then return _ERR(_rcode) end

	return _res;
end;