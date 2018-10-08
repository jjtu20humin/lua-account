-- auth

GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "设置应用包授权",
	desc = "设置应用包授权", 
	base_param = {
		{ name = "secret",pattern = ".+", length = {1,}, helper = {"密钥","字符串"} },		
		{ name = "app_id",pattern = ".+", length = {1,}, helper = {"客户id","string"} },
		{ name = "package_name",pattern = ".+", length = {1,}, helper = {"包名","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","md5hex"}	},
	},

	opt_param = {
	},
};


GV_IFS[_module_]['callback'] = function(_REQ, _FILE )
	local _secret = _REQ["secret"];
	local _app_id = _REQ["app_id"];
	local _package_name = _REQ["package_name"];

	local secret_key = "DroiAccount(auth)_app@droi*#2017"
	if (_secret~=secret_key) then
		return _ERR(-10304);
	end

	local _rcode = app_upsert( _package_name, _app_id );
	if _rcode < 0 then return _ERR(_rcode) end

	return { ok = 1 };
end;