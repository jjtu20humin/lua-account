-- login

GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "用户登录",
	desc = "用户登录，支持手机/邮箱登录", 
	base_param = {
		{ name = "uid", pattern = "[%w-%.@%_]+", length = {1,}, helper = {"用户id","字符串"}, },
		{ name = "passwd", pattern = ".+", length = {4,48}, helper = {"密码","MD5密码"} },
		{ name = "utype", pattern = {"zhuoyou","mail","anonym"}, length = {4,10}, helper = {"用户类型",""} },
		{ name = "app_id",pattern = ".+", length = {1,}, helper = {"客户id","string"} },
		{ name = "package_name",pattern = ".+", length = {1,}, helper = {"包名","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","md5hex"}	},
	},

	opt_param = {
		{ name = "device_id", pattern = ".+", length = {1,64}, helper = {"客户端ID","string"} },
	},
};

GV_IFS[_module_]['callback'] = function(_REQ, _FILE )
	local _uid = _REQ["uid"];
	local _passwd = _REQ["passwd"];
	local _utype = _REQ["utype"];
	local _app_id = _REQ["app_id"];
	local _package_name = _REQ["package_name"];

	local _rcode = app_check( _package_name, _app_id );
	if _rcode < 0 then return _ERR(_rcode) end

	local _rcode, _ret = user_login( _uid, _passwd, _utype );
	if _rcode < 0 then
		return _ERR( _rcode );
	end
	
	if (_utype=="anonym" and _ret.username and #tostring(_ret.username)>0 and  not string.find(_ret.username,"%a") ) then
		local _result = {
			result = 1,
			username = _ret.username,
		}

		return _result;
	end
	local _unique_id = str_crypt( _ret.openid );
	local _expire = config.login_expire;
	
	local _rcode, _token, _expire = oauth_session_new(_unique_id, _uid, _ret.username, _ret.mail, _ret.openid, _ret.nickname, _utype, _passwd, _expire, _app_id);
	if _rcode < 0 then
		return _ERR( _rcode );
	end



	local _result = {};
	_result.result = 0;
	_result.token = _token;
	_result.expire = _expire + ngx.time();
	_result.openid = _unique_id;
	_result.userinfo = _ret;
	_result.userinfo.openid = nil;
	if (_utype=="anonym") then
		_result.userinfo.anonym = _ret.nickname;
	end

	return _result;
end;
