GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "删除用户",
	desc = "删除用户", 
	base_param = {
		{ name = "uid", pattern = ".+", length = {1,}, helper = {"用户id","字符串"}, },
		{ name = "utype", pattern = {"qq","weibo","wechat","mobile","mail","anonym","id"}, length = {2,6}, helper = {"类型","type"} },
	},

	opt_param = {
	},
};

GV_IFS[_module_]['callback'] = function(_REQ, _FILE )

	local _uid = _REQ["uid"];
	local _utype = _REQ["utype"];

	local delete_sql;
	if _utype == "qq" then
		delete_sql = "DELETE FROM droi_qq_user where qq_id = '".._uid.."';";
	elseif _utype == "weibo" then
		delete_sql = "DELETE FROM droi_account where weibo_id = '".._uid.."';";
	elseif _utype == "wechat" then
		delete_sql = "DELETE FROM droi_account where wechat_id = '".._uid.."';";
	elseif _utype == "mobile" then
		delete_sql = "DELETE FROM droi_account where username = '".._uid.."';";
	elseif _utype == "anonym" then
		delete_sql = "DELETE FROM droi_account where device_id = '".._uid.."';";
	elseif( _utype== "id") then
		delete_sql = "DELETE FROM droi_account where id = '".._uid.."';";
	end

	local pg = pg_init();
    local res = pg:query(delete_sql);
    pg_cleanup(pg); 
    
    local result = {};
    if res and res.affected_rows > 0 then
        result.result = 0;
        result.desc = "删除成功";
    end
    
    result.result = -1;
    result.desc = "账号不存在";

    return result;
end;
