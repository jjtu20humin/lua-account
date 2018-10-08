-- bindmobile

GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
    name = _module_,
    cname = "绑定mobile",
    desc = "绑定现有账户+mobile",
    base_param = {
        { name = "uid", pattern = "%w+", length = {3,40}, helper = {"手机号", "数字"} },
        { name = "randcode", pattern = "[0-9]+", length = {6,6}, helper = {"验证码","6位数字"} },
        { name = "token", pattern = "[%w-]+", length = {32,48}, helper = {"令牌","ascii字符，绑定账户必填"} },
        { name = "app_id", pattern = ".+", length = {1,}, helper = {"应用id","string"} },
        { name = "package_name", pattern = ".+", length = {1,}, helper = {"包名","string"} },
        { name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","md5字符串"}    },
    },
    opt_param = {
        { name = "passwd", pattern = ".+", length = {4,48}, helper = {"密码","明文密码"} },
    },
};

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )
    local _uid = _REQ['uid'];
    local _randcode = _REQ['randcode'];
    local _token = _REQ['token'];
    local _passwd = _REQ['passwd'];
    local _app_id = _REQ["app_id"];
    local _package_name = _REQ["package_name"];

    local _rcode = app_check( _package_name, _app_id );
    if _rcode < 0 then return _ERR(_rcode) end

    local _rcode, _ret = randcode_get(_token);
    if _rcode < 0 then
        return  _ERR( -10020 );
    end
    if _uid ~= _ret.userid then
        return  _ERR( -10042 );
    end
    if _randcode ~= _ret.randcode then
        return  _ERR( -10041 );
    end

    local _rcode, _openid;
    if _ret.step == "qqbind" then
        _rcode, _openid = qq_bind_mobile( _uid, _ret.tid, _app_id, _passwd );
        if _rcode < 0 then
            return _ERR( _rcode );
        end 
    elseif _ret.step == "bindmobile" then
    	_openid = _ret.openid;
        _rcode = other_bind_mobile( _uid, _ret.openid, _passwd );
        if _rcode < 0 then
            _ERR( _rcode );
        end 
    else
        return  _ERR( -10043 );
    end

    local _rc, _ret = userinfo(_openid);
    if _rc < 0 then return _ERR(-10051) end;

    local _unique_id = str_crypt( _openid );
	local _expire = config.login_expire;
	
	local _rcode, _token, _expire = oauth_session_new(_unique_id, _uid, _ret.username, _ret.mail, _ret.openid, _ret.nickname, '', '', _expire, _app_id);
	if _rcode < 0 then
		return _ERR( _rcode );
	end


    local _result = { result = 0, desc = "绑定成功" };
    _result.token = _token;
    _result.openid = _unique_id;
    _result.userinfo = _ret;
	_result.userinfo.openid = nil;
    return _result;
end;