GV_IFS = GV_IFS or {};  
local _module_ = (...):match( "^.*%.(.*)$" );  

GV_IFS[_module_] = {  
	name = _module_, 
	cname = "用户信息",
	desc = "获取用户信息",
	base_param = { 
		{ name = "openid", pattern = "%w+", length = {24,32}, helper = {"用户标示","ascii字符串"}, },
		{ name = "token", pattern = "%w+", length = {24,32}, helper = {"令牌","ascii字符串"}, },
		{ name = "app_id",pattern = ".+", length = {1,}, helper = {"客户id","string"} },
		{ name = "package_name",pattern = ".+", length = {1,}, helper = {"包名","string"} },
		--{ name = "scope", pattern = "[%w,]+", length = {1,}, helper = {"用户权限","字符串"}, },		
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","32byte md5hex值"}  },

	},
	opt_param = {
	}
}

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE ) 
	
	local _req_openid = _REQ['openid']
	local _token = _REQ['token']
	local _app_id = _REQ["app_id"];
	local _package_name = _REQ["package_name"];

	local _rcode = app_check( _package_name, _app_id );
	if _rcode < 0 then return _ERR(_rcode) end

	local _code, _unique_id, _openid, _app_id  = oauth_session_get_info(_token)
	if _code < 0 then
		return _ERR(-10300);
	end
	if _req_openid ~= _unique_id then
		return _ERR(-10301);
	end

	local _code, _ret = userinfo(_openid)
	if _code < 0 then
		return _ERR(-10303);
	end
	_ret.openid = nil;
	_ret.result = 0;

	return _ret; 
end  
