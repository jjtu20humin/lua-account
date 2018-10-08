GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "用户是否存在(openid)",
	desc = "通过openid检查用户是否存在",
	base_param = {
		{ name = "openid", pattern = ".+", length = {32,48}, helper = {"用户id","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","32byte md5hex值"}	},
	},

	opt_param = {

	},
};

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )

	local _req_openid = _REQ["openid"];
	local _openid = str_orig(_req_openid);
	if not _openid then return _ERR(-10012) end

	local _rcode = userinfo(_openid);

	local _result = {};
	if _rcode < 0 then
		_result.result = -1;
		_result.desc = "用户不存在";
	else
		_result.result = 0;
		_result.desc = "用户存在";
	end
	return _result;
end
