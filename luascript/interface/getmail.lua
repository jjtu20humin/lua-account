GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "邮件请求",
	desc = "获取邮件，用于用户注册邮箱及绑定、修改密码等功能",
	base_param = {
		{ name = "mail", pattern = "[%w_.]-@[%w.]+", length = {1,48}, helper = {"邮箱","ascii字符串以及_@."} },
		{ name = "codetype", pattern = {"findpasswd","bindmail","resend"}, helper = {"邮件目的",""} },
		{ name = "app_id", pattern = ".+", length = {1,}, helper = {"应用id","string"} },
        { name = "package_name", pattern = ".+", length = {1,}, helper = {"包名","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","32byte md5hex值"}	},
	},

	opt_param = {
		{ name = "passwd", pattern = ".+", length = {4,48}, helper = {"密码","明文密码"} },
		{ name = "openid", pattern = "%w+", length = {24,32}, helper = {"卓悠ID","ascii字符串"}, },
		{ name = "token", pattern = "%w+", length = {24,32}, helper = {"令牌","ascii字符串"}, },
	},
};

local function get_mail_content( codetype, mail, maillink )
	local theme = "";
	local content = "";

	if codetype == "userreg" then
		theme = _TIP(1010);
		content = _TIP(1013,nil,mail,maillink,maillink);
	elseif codetype == "findpasswd" then
		theme = _TIP(1011);
		content = _TIP(1014,nil,mail,maillink,maillink);
	elseif codetype == "bindmail" then
		theme = _TIP(1012);
		content = _TIP(1015,nil,mail,maillink,maillink);
	end

	return theme, content;
end

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )
	local _mail = _REQ['mail'];
	local _codetype = _REQ['codetype'];
	local _passwd = _REQ['passwd'];
	local _req_openid = _REQ['openid']
	local _token = _REQ['token'];
	local _app_id = _REQ["app_id"];
    local _package_name = _REQ["package_name"];

    local _rcode = app_check( _package_name, _app_id );
    if _rcode < 0 then return _ERR(_rcode) end

	local _rcode, _expire, _mail_id, _checkno, _tmp_mail, _openid ;
	
	local _user_exist = user_checkexist( _mail, "mail" );		--0: exists; other: not exists;
	if _codetype == "bindmail" then
		if _user_exist == 0 then return _ERR(-10011) end;
		if not _token or not _req_openid then return _ERR(-10095) end;

		local _code, _unique_id, _ropenid, _app_id  = oauth_session_get_info(_token);
		if _code < 0 then
			return _ERR(-10300);
		end
		if _req_openid ~= _unique_id then
			return _ERR(-10301);
		end

		_openid = _ropenid;
	elseif _codetype == "resend" then
		_rcode, _tmp_mail = user_mailstore_checkexist( _mail );
		if _rcode < 0 then
			return _ERR(-10090);
		else
			_mail_id = _tmp_mail[1].mail_id;
			_checkno = _tmp_mail[1].checkno;
		end
	elseif _codetype == "findpasswd" then
		if _user_exist < 0 then return _ERR(-10010) end;
	end

	local _result = {};
	if _codetype == "resend" then
		_codetype = _tmp_mail[1].codetype;
	else
		_rcode, _mail_id, _checkno, _expire = user_create_tmp_mail_account( _mail, _codetype, nil, nil, _passwd, _openid, _app_id, _device_id, _request_id);		
		if _rcode < 0 then
			return _ERR( _rcode );
		end
	end

	_result["mail_link"] = config.mail_link.."/actmail/".._mail_id.."/".._checkno;
	local _theme, _content = get_mail_content( _codetype, _mail, _result['mail_link'] );

	_result.result = 0;
	_result.desc = _TIP(1016);
	_result.mail = _mail;
	_result.expire = _expire;
	_result.mailcontent = _content;
	_result.mail_id = _mail_id;
	_result.checknumber = _checkno;

	local _code ,_err = lua_send_mail(_mail ,_theme ,_content);
	if _code < 0 then return _ERR(-10031); end;

	return _result;
end

