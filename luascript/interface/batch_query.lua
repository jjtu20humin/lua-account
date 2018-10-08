GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "批量搜索用户信息",
	desc = "通过openid批量搜索用户信息",
	base_param = {
		{ name = "list", pattern = ".+", length = {1,}, helper = {"用户id列表","string"} },
		{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","32byte md5hex值"}	},
	},

	opt_param = {

	},
};

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )
	local _list= _REQ["list"];

	local _rcode, _ret = batch_query(_list);
	if _rcode < 0 then return _ERR(_rcode) end

	return _ret;
end

