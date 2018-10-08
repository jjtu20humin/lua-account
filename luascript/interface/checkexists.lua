GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "用户是否存在",
	desc = "检查用户是否存在",
	base_param = {
		{ name = "uid", pattern = ".+", length = {1,48}, helper = {"用户id","string"} },
		{ name = "utype", pattern = {"mail","zhuoyou","anonym"}, helper = {"用户类型",""} },
		{ name = "app_id", pattern = ".+", length = {1,}, helper = {"应用id","string"} },
        { name = "package_name", pattern = ".+", length = {1,}, helper = {"包名","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","32byte md5hex值"}	},
	},

	opt_param = {

	},
};

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )
	local _uid = _REQ["uid"];
	local _utype = _REQ["utype"];
	local _app_id = _REQ["app_id"];
	local _package_name = _REQ["package_name"];

	local _rcode = app_check( _package_name, _app_id );
	if _rcode < 0 then return _ERR(_rcode) end

	local _rcode = user_checkexist(_uid, _utype);
	_result = { result = 0 };
	if _rcode < 0 then
		_result.exists = false
		_result.desc = "用户不存在";
	else 
		_result.exists = true
		_result.desc = "用户已存在";
	end

	return _result;
end

