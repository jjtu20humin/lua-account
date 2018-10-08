-- signup

GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "用户注册",
	desc = "手机用户注册接口", 
	base_param = {
		{ name = "token", pattern = "%w+", length = {24,32}, helper = {"令牌","ascii字符串"}, },
		{ name = "passwd", pattern = ".+", length = {4,48}, helper = {"密码","明文密码"} },
		{ name = "regtype", pattern = {"randreg"}, helper = {"注册步骤",""} },
		{ name = "app_id",pattern = ".+", length = {1,}, helper = {"客户id","string"} },
		{ name = "package_name",pattern = ".+", length = {1,}, helper = {"包名","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","md5hex"}	},
	},

	opt_param = {
		{ name = "randcode", pattern = "%d+", length = {6,6}, helper = {"验证码","数字验证码"}, default = nil, checksign = true },
	},
}

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )
	local _token = _REQ['token'];
	local _passwd = _REQ['passwd'];
	local _regtype = _REQ['regtype'];
	local _randcode = _REQ['randcode'];
	local _app_id = _REQ["app_id"];
	local _package_name = _REQ["package_name"];

	local _rcode = app_check( _package_name, _app_id );
	if _rcode < 0 then return _ERR(_rcode) end

	local _code, _ret = randcode_get(_token);
	
	if _code < 0 then return _ERR( -10040 ) end
	if _regtype == "randreg" then
		if not _randcode or _randcode ~= _ret.randcode then
			return _ERR( -10041 );
		end
		if _ret.step ~= "getrand" then
			return _ERR( -10021 );
		end
	end

	local _uid = _ret.userid;
	local _code, _result = user_regist( _uid, _passwd, "zhuoyou" );
	if _code < 0 then
		return _ERR( _code );
	end

	randcode_remove(_token);

	local _response = {};
	_response.result = 0;
	_response.openid = str_crypt( _result.openid );
	return _response;
end
