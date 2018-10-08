-- auth

GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "授权",
	desc = "第三方授权登录", 
	base_param = {
		{ name = "data",pattern = ".+", length = {1,}, helper = {"用户数据","json字符串"} },
		{ name = "utype", pattern = {"qq","weibo","wechat"}, length = {2,6}, helper = {"授权类型","string"} },
		{ name = "app_id",pattern = ".+", length = {1,}, helper = {"客户id","string"} },
		{ name = "package_name",pattern = ".+", length = {1,}, helper = {"包名","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","md5hex"}	},
	},

	opt_param = {
		{ name = "device_id", pattern = ".+", length = {1,64}, helper = {"客户端ID","string"} },
	},
};

local function parse_3rd_data(data)
	local _openid = data.openid;
	if not _openid then return nil end
	return {
		openid = data.openid,
		nickname = data.nickname or _TIP(1000),
		avatar = data.avatar,
		gender = type(data.gender) == "number" and data.gender or  _TIP(1001),
	}
end

GV_IFS[_module_]['callback'] = function(_REQ, _FILE )
	local _data = _REQ["data"];
	local _utype = _REQ["utype"];
	local _app_id = _REQ["app_id"];
	local _package_name = _REQ["package_name"];

	local _rcode = app_check( _package_name, _app_id );
	if _rcode < 0 then return _ERR(_rcode) end

	local _data_tab = cjson_safe.decode(_data);
	if not _data_tab then return _ERR(-10400) end
	local _3rd_userinfo = parse_3rd_data(_data_tab);
	if not _3rd_userinfo then return _ERR(-10400) end

	local _id = _3rd_userinfo.openid;
	local _code, _ret = check_3rd_exist( _id, _utype, _app_id );

	local _result = {};
	if _code == 1 then				--exists
		ngx.log(ngx.NOTICE,"~~~~~~~~~~~~"..cjson_safe.encode(_ret));
		local _openid = _ret[1].openid;
		local _rcode, _ret = userinfo(_openid);
		if _code < 0 then
			return _ERR(-10303);
		end

		local _unique_id = str_crypt( _ret.openid );
		local _expire = config.login_expire;
		local _rcode, _token, _expire = oauth_session_new(_unique_id, _id, _ret.username, _ret.mail, _ret.openid, _ret.nickname, '', '', _expire, _app_id);
		if _rcode < 0 then
			return _ERR( _rcode );
		end

		_result.result = 0;
		_result.token = _token;
		_result.expire = _expire + ngx.time();
		_result.openid = _unique_id;
		_result.userinfo = _ret;
		_result.userinfo.openid = nil;
	elseif _code == 2 then			--exists, need bind mobile
		_result.result = 0;
		_result.forcebind = true;
	else 							--not exist
		local _rcode, _ret = third_user_regist( _id, _utype, _3rd_userinfo, _app_id);
		if _rcode < 0 then
			return _ERR( _rcode );
		end

		_result.result = 0;
		if _ret.forcebind then
			_result.forcebind = true;
		else
			local _unique_id = str_crypt( _ret.openid );
			local _expire = config.login_expire;
			local _rcode, _token, _expire = oauth_session_new(_unique_id, _id, _ret.username, _ret.mail, _ret.openid, _ret.nickname, '', '', _expire, _app_id);
			if _rcode < 0 then
				return _ERR( _rcode );
			end

			_result.token = _token;
			_result.expire = _expire + ngx.time();
			_result.openid = _unique_id;
			_result.userinfo = _ret;
			_result.userinfo.openid = nil;
		end
	end

	return _result;
end;