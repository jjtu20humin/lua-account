-- resetpass

GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "重置密码",
	desc = "用户重置密码，通过获取短信校验码重置",
	base_param = {
		{ name = "token", pattern = "%w+", length = {24,32}, helper = {"令牌","ascii字符串"}, },
		{ name = "passwd", pattern = ".+", length = {4,48}, helper = {"密码","明文密码"} },
		{ name = "randcode", pattern = "%d+", length = {6,6}, helper = {"验证码","数字验证码"},},
		{ name = "app_id", pattern = ".+", length = {1,}, helper = {"应用id","string"} },
		{ name = "package_name",pattern = ".+", length = {1,}, helper = {"包名","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","md5hex"}	},
	},

	opt_param = {
	},

};

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )
	local token = _REQ['token'];
	local passwd = _REQ['passwd'];
	local randcode = _REQ['randcode'];
	local _app_id = _REQ["app_id"];
	local _package_name = _REQ["package_name"];

	local _rcode = app_check( _package_name, _app_id );
	if _rcode < 0 then return _ERR(_rcode) end

	local code, ret = randcode_get(token);
	if code < 0 then
		return	_ERR( -10020 );
	end
	if ret.codetype ~= "resetpasswd" then
		return _ERR( -10080 );
	end
	if not randcode or randcode ~= ret.randcode then
		return _ERR( -10081 );
	end

	local username = ret.userid;
	local code = user_resetpwd_byuid( username, passwd );
	if code < 0 then
		return _ERR( code );
	end

	randcode_remove(token);

	local result = {};
	result.result = 0;
	return result;
end;
