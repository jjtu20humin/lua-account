GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
    name = _module_,
    cname = "修改用户信息",
    desc = "修改用户基本资料",
    base_param = {
        { name = "openid", pattern = "[%w-]+", length = {32,48}, helper = {"卓悠ID","ascii字符串"}, },
        { name = "token",pattern = "[%w-]+", length = {32,48}, helper = {"令牌","ascii字符串"}, },
        { name = "app_id", pattern = ".+", length = {1,}, helper = {"应用id","string"} },
        { name = "package_name",pattern = ".+", length = {1,}, helper = {"包名","string"} },
        { name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","md5hex"}   },
    },

    opt_param = {
        { name = "data", pattern = ".+", length = {4,}, helper = {"用户数据资料","json string"}, },
    },

};

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )
    local _req_openid = _REQ['openid'];
    local _token = _REQ['token'];
    local _app_id = _REQ["app_id"];
    local _data = _REQ["data"];
    local _package_name = _REQ["package_name"];

    local _rcode = app_check( _package_name, _app_id );
    if _rcode < 0 then return _ERR(_rcode) end

    local _code, _unique_id, _openid, _app_id  = oauth_session_get_info(_token);
    if _code < 0 then
        return _ERR(-10300);
    end
    if _req_openid ~= _unique_id then
        return _ERR(-10301);
    end

    local _rcode = useredit(_openid, cjson_safe.decode(_data));
    if _rcode < 0 then
        return _ERR(_rcode);
    end

    return { result = 0, desc = "更新成功" };
end;