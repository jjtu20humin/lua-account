GV_IFS = GV_IFS or {}; 
local _module_ = (...):match( "^.*%.(.*)$" ); 

GV_IFS[_module_] = { 
	name = _module_,  
	cname = "验证码请求",
	desc = "获取短信验证码，用于用户注册及手机绑定等相关业务",
	base_param = { 
		{ name = "uid", pattern = ".+", length = {9,15}, helper = {"手机号", "11位手机号码"} },
		{ name = "codetype", pattern = {"userreg", "resetpasswd", "bindmobile"}, helper = {"验证码","6位数字验证码"} },
		{ name = "app_id", pattern = ".+", length = {1,}, helper = {"应用id","string"} },
		{ name = "package_name",pattern = ".+", length = {1,}, helper = {"包名","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","32byte md5hex值"}  },
	},
	opt_param = {
		{ name = "tid", pattern = "%w+", length = {24,32}, helper = {"第三方id", "ascii字符串"} },
		{ name = "token", pattern = "%w+", length = {24,32}, helper = {"令牌", "ascii字符串"} },
		{ name = "device_id", pattern = ".+", length = {1,64}, helper = {"设备ID","string"} },
	}
}

local function utf8_to_gbk( str )
	local iconv = require "iconv";
	local iconv_obj = iconv.new( 'GBK','utf-8' );
	return iconv_obj:iconv(str);
end

local function encodeURI(s)
	s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
	return string.gsub(s, " ", "+")
end

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )  

	local _uid = _REQ["uid"];
	local _codetype = _REQ["codetype"];
	local _app_id = _REQ["app_id"];
	local _package_name = _REQ["package_name"];
	local _tid = _REQ["tid"];
	local _token = _REQ["token"];
	local _device_id = _REQ["device_id"];

	local _rcode = app_check( _package_name, _app_id );
	if _rcode < 0 then return _ERR(_rcode) end
	
	local _code, _randcode, _expire, _ret;
	local _pattern = config.sms["zh_CN"]["pattern"]; 
	local _gbk_pattern = utf8_to_gbk( _pattern );

	local _userexist = user_checkexist( _uid );	--0 exist, -1 not exist;
	if ( _codetype == "userreg" ) then
		if _userexist == 0 then return _ERR(-10011) end
	elseif ( _codetype == 'bindmobile' ) then
		if _tid then							--qq user, can bind to existed mobile						
			local _qq2mobile = check_qq2mobile_status( _uid, _app_id );
			if _qq2mobile == 0 then return _ERR(-10011) end
		elseif _token then						--weibo/wechat user, can`t bind to existed mobile
			if _userexist == 0 then return _ERR(-10011) end
		end
 	else
		if _userexist < 0 then return _ERR(-10010) end
	end

	local passwd_status = 0;	--not set
	math.randomseed(ngx.time());
	_randcode = tostring( math.random( 100000, 999999 ) );
	if (_codetype == "bindmobile") then
			if _tid then
				local _rc = check_3rd_exist( _tid, "qq", _app_id );
				if _rc ~= 2 then return _ERR(-10047) end
				if _userexist == 0 then
					passwd_status = 1;
				end
				_code, _token, _expire = randcode_new(_uid, _codetype, _randcode, "qqbind", _app_id, nil, _tid);
				if _code < 0 then return _ERR(-100) end
			elseif _token then
				local _rc, _, _openid, _  = oauth_session_get_info(_token);
				if _rc < 0 then
			        return _ERR(-10300);
			    end
			    local _rc, _passwd = user_passwd_status(_openid);
				if _rc < 0 then
					return _ERR(-10303);
				end
				if _passwd then passwd_status = 1 end;		--passwd set
			    _code, _token, _expire = randcode_new(_uid, _codetype, _randcode, "bindmobile", _app_id, _openid, nil);
			    if _code < 0 then return _ERR(-100) end
			else
				return _ERR(-10046);
			end
	else
			_code, _token, _expire = randcode_new(_uid, _codetype, _randcode, "getrand", _app_id);
			if _code < 0 then return _ERR(-100) end
	end
	local _utf8_pattern = string.format( _pattern, config.sms["zh_CN"]["regex"] );
	local _smsstring = string.format( _gbk_pattern, _randcode );

--	local sms_req = "/cgi-bin/sendsms?username=shzywl@shzywl&password=C048:-V!";
	local _sms_req = "http://211.147.239.62:9050/cgi-bin/sendsms?username=shzywl@shzywl&password=kfsuZm77";
	local _sms_mobile = "&to=".._uid;
	local _url = _sms_req.._sms_mobile.."&text="..encodeURI( _smsstring ).."&msgtype=1";
	
	local _code, _ret = http_GET(_url);
	if not _code or _code ~= 200 then
		_code, _ret = http_GET(_url);
	end
	ngx.log(ngx.NOTICE,"~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~".._randcode);
	local _response = {};
	if _code and _code == 200 and tonumber(_ret) == 0 then
		_response.result = 0;
		_response.desc = "OK";
		_response.uid = _uid;
		_response.token = _token;
		_response.expire = _expire;
		_response.passwd_status = passwd_status;
	else
		return _ERR(-10030);
	end
	return _response;
end
