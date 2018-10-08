-- auth

GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "游客注册登录",
	desc = "获取游客帐号和密码", 
	base_param = {		
		{ name = "app_id",pattern = ".+", length = {1,}, helper = {"客户id","string"} },
		{ name = "package_name",pattern = ".+", length = {1,}, helper = {"包名","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","md5hex"}	},
	},

	opt_param = {
		{ name = "data",pattern = ".+", length = {1,}, helper = {"用户数据","json字符串"} },
		{ name = "device_id", pattern = ".+", length = {1,64}, helper = {"客户端ID","string"} },
	},
};

local function randId()
	local str = "abcdefghijklmnopqrstuvwxyzZBCDEFGHIJKLMNOPQRSTUVWXYZ"
	local len = #str;
	local rand = ngx.now()*1000%len+1
	local val = string.sub(str,rand,rand)
	return val .. string.sub(tostring(ngx.time()),4,-1);
end

local function parse_3rd_data(data)
	local _openid = data.openid ;
	if not _openid then return nil end
	return {
		openid = data.openid,
		nickname = data.nickname or _TIP(1000),
		avatar = data.avatar,
		gender = type(data.gender) == "number" and data.gender or  _TIP(1001),
	}
end

GV_IFS[_module_]['callback'] = function(_REQ, _FILE )
	local _data = _REQ["data"] or {};	
	local _app_id = _REQ["app_id"];
	local _package_name = _REQ["package_name"];
	
	local _uid = randId() 
	local _passwd = "123456";
	local _utype = "anonym";

	local _rcode = app_check( _package_name, _app_id );
	if _rcode < 0 then return _ERR(_rcode) end
	
	local _3rd_userinfo = {
		openid = _data.openid or _uid,
		nickname = _data.nickname or _uid or _TIP(1000),
		avatar = _data.avatar,
		gender = type(_data.gender) == "number" and _data.gender or  _TIP(1001),
	}	

	local _code, _result = user_regist( _uid, _passwd, _utype , _3rd_userinfo);
	if _code < 0 then
		return _ERR( _code );
	end

	local _rcode, _ret = user_login( _uid, md5hex(_passwd), _utype );
	if _rcode < 0 then
		return _ERR( _rcode );
	end

	local _unique_id = str_crypt( _ret.openid );
	local _expire = config.login_expire;
	
	local _rcode, _token, _expire = oauth_session_new(_unique_id, _uid, _ret.username, _ret.mail, _ret.openid, _ret.nickname, _utype , md5hex(_passwd), _expire, _app_id);
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
	_result.passwd = _passwd;
	_result.anonym = _uid

	return _result;
end;