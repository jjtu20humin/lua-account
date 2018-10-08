function check_qq2mobile_status( uid, app_id )
        local query = "SELECT a.* FROM droi_account a, droi_qq_user b WHERE a.openid = b.openid and a.username = '"..uid.."' and b.app_id = '"..app_id.."';";

        local pg = pg_init();
        local res = pg:query(query);
        pg_cleanup(pg); 
        if res and res[1] then
                return 0;               --exists
        end
        return -1;                      --not exists
end

function qq_bind_mobile( uid, tid, app_id, passwd )
        if not tid or not app_id then return -10046 end;
        local query = "SELECT * FROM droi_qq_user WHERE qq_id = '"..tid.."' and app_id = '"..app_id.."';";
        local pg = pg_init();
        local res = pg:query(query);
        if not res or not res[1] then
                pg_cleanup(pg);
                return -10010;
        end

        local openid;
        local rcode, ret = user_checkexist( uid, "zhuoyou" );
        if rcode == 0 then              --user exists
                openid =  delete_hyphen(ret[1].openid);
        else                            --user not exists, need regist
                local extdata = {};
                extdata.avatar = res[1].avatar;
                extdata.nickname = res[1].nickname;
                extdata.gender = res[1].gender;
                if not passwd then return -10044 end;
                local rcode, ret = user_regist(uid, passwd, "zhuoyou", extdata);
                if rcode == 0 then
                        openid = ret.openid; 
                else
                        return -10050;
                end
        end

        local update_sql = "UPDATE droi_qq_user SET openid = '"..openid.."' WHERE qq_id = '"..tid.."' and app_id = '"..app_id.."';";
        local res = pg:query(update_sql);
        if res and res.affected_rows > 0 then
                pg_cleanup(pg);

                ngx.log(ngx.NOTICE,"======xxxxxxxxxxxxxxx=====");
                local query = "SELECT a.*, b.qq_id FROM droi_account a, droi_qq_user b WHERE a.openid = '"..openid.."' and b.qq_id = '"..tid.."' and b.app_id = '"..app_id.."';";
                sync_user( query );

                return 0, openid;
        end

        pg_cleanup(pg);

        return -10045;
end

function other_bind_mobile( uid, openid, passwd )
        if not openid then return -10046 end;
        local query = "SELECT * FROM droi_account WHERE openid = '"..openid.."';";
        local pg = pg_init();
        local res = pg:query(query);
        if not res or not res[1] then
                pg_cleanup(pg);
                return -10010;
        end
        if not res[1].passwd and not passwd then
                return -10044;
        end

        local update_sql;
        if res[1].passwd then
                update_sql = "UPDATE droi_account SET username = '"..uid.."' WHERE openid = '"..openid.."';";
        else
                update_sql = "UPDATE droi_account SET username = '"..uid.."',passwd = '"..passwd.."', passwdmd5 = '"..md5hex(passwd).."' WHERE openid = '"..openid.."';";
        end
        local res = pg:query(update_sql);
        if res and res.affected_rows > 0 then
                pg_cleanup(pg);

                local query = "SELECT * FROM droi_account WHERE openid = '"..openid.."';";
                sync_user( query );

                return 0;
        end

        pg_cleanup(pg);

        return -10045;
end

function check_3rd_exist( id, utype, app_id )
        local query;
        if ( utype == "qq" ) then
                query = "SELECT * FROM droi_qq_user WHERE qq_id = '"..id.."' and app_id = '"..app_id.."';";
        elseif ( utype == "weibo" ) then
                query = "SELECT * FROM droi_account WHERE weibo_id = '"..id.."';";
        elseif( utype == "wechat" ) then
                query = "SELECT * FROM droi_account WHERE wechat_id = '"..id.."';";
        else
                query = "SELECT * FROM droi_account WHERE device_id = '"..id.."';";
        end
        local pg = pg_init();
        local res = pg:query(query);

        local code;                --0: not exists; 1: exists; 2: exists, need bind mobile
        if ( utype == "qq" ) then
                if not res or not res[1] then
                        code = 0;
                elseif res[1].openid then
                        code = 1;
                else
                        code = 2;
                end
        else
                if res and res[1] then
                        code = 1;
                else
                        code = 0;
                end
        end
        pg_cleanup(pg);
        return code, res;
end

function select_user( uid, utype )
        local query;
        if ( utype =="mail" ) then
                query = "SELECT * FROM droi_account WHERE mail = '"..uid.."';";
        elseif (utype=="anonym") then
			query = "SELECT * FROM droi_account WHERE device_id = '"..uid.."';";
		else
                query = "SELECT * FROM droi_account WHERE username = '"..uid.."';";
        end
        local pg = pg_init();
        local res = pg:query(query);
        pg_cleanup(pg);
        return res;
end

function user_checkexist( uid, usertype )
        local res = select_user( uid, usertype );
        if not res or not res[1] then
                return -10010;
        end
        return 0, res;
end

function parse_userinfo(info)
        return {
                openid = delete_hyphen(info[1].openid),
                username = info[1].username,
                nickname = info[1].nickname or info[1].username or info[1].mail or _TIP( 1000 ),
                gender = info[1].gender or _TIP( 1001 ),
                avatar = info[1].avatar,
                age = info[1].age,
                birthday = info[1].birthday,
                mail = info[1].mail,
        };
end

function user_login( uid, passwd, utype )
        local res = select_user( uid, utype );

        if not res or not res[1] then
                return -10010;
        end
        if res[1].passwdmd5 ~= passwd then
                return -10052;
        end

        return 0, parse_userinfo(res);
end

function user_passwd_status(openid)
        local query = "SELECT * FROM droi_account WHERE openid = '"..openid.."';";
        local pg = pg_init();
        local res = pg:query(query);
        if not res or not res[1] then
                pg_cleanup(pg);
                return -1;
        end
        pg_cleanup(pg);
        return 0, res[1].passwd;
end

function userinfo(openid)
        local openid = openid;
        local query = "SELECT * FROM droi_account WHERE openid = '"..openid.."';";
        local pg = pg_init();
        local res = pg:query(query);
        if not res or not res[1] then
                pg_cleanup(pg);
                return -1;
        end
        pg_cleanup(pg);
        return 0, parse_userinfo(res);
end

function useredit(openid, data)
        if type(data) ~= "table" then return -10054 end;
	local nick = data.nickname;
	if nick then
		nick = nick:gsub("'","''");
	end 
        local tab = {
                nickname = nick,
                gender = data.gender,
                birthday = data.birthday,
                age = data.age
        }
        if not next(tab) then return 0 end;

        local values = parse_equal_values(tab);
        local update_pattern = "UPDATE droi_account SET %s WHERE openid = '"..openid.."';";
        local update_sql = update_pattern:format(values);

        local pg = pg_init();
        local res = pg:query(update_sql);
        if res and res.affected_rows > 0 then
                pg_cleanup(pg);

                local query = "SELECT * FROM droi_account WHERE openid = '"..openid.."';";
                sync_user( query );

                return 0;
        end

        pg_cleanup(pg);

        return -10053;
end

function third_user_regist( uid, utype, extdata, app_id )
        local pg = pg_init();

        local query;
        local nickname = extdata.nickname or "";
	local nick = nickname:gsub("'","''");
        local gender = extdata.gender or _TIP(1001);
        local age = extdata.age or 1;
        local birthday = extdata.birthday or '1970-1-1';
        local avatar = extdata.avatar or '';


        if ( utype == "weibo" ) then
                query = "SELECT * FROM droi_account WHERE weibo_id = '"..uid.."';";
        elseif ( utype == "wechat" ) then
                query = "SELECT * FROM droi_account WHERE wechat_id = '"..uid.."';";
        else
                query = "SELECT a.* FROM droi_account a, droi_qq_user b WHERE a.openid = b.openid and b.app_id = '"..app_id.."' and b.qq_id ='"..uid.."';"
        end

        local res = pg:query(query);
        if res and res[1] then --user exists 
                pg_cleanup(pg);         
                return third_user_login( uid, utype, app_id );        --login
        end

        if ( utype == "weibo" or utype == "wechat" ) then
                local insert_sql;
                if ( utype == "weibo" ) then
                        insert_sql = "INSERT INTO droi_account(nickname, gender, birthday, age, avatar, weibo_id) VALUES('"..nick.."', '"..gender.."', '"..birthday.."', '"..age.."', '"..avatar.."','"..uid.."') RETURNING openid;"
                elseif ( utype == "wechat" ) then
                        insert_sql = "INSERT INTO droi_account(nickname, gender, birthday, age, avatar, wechat_id) VALUES('"..nick.."', '"..gender.."', '"..birthday.."', '"..age.."', '"..avatar.."','"..uid.."') RETURNING openid;"
                end

                local openid ;
                local res = pg:query(insert_sql);
                if res and res[1] then
                        openid = delete_hyphen(res[1].openid); 
                else
                        pg_cleanup(pg);
                        return -10050; 
                end

                pg_cleanup(pg);

                local result = { result = 0 };  
                result.openid = openid;
                result.gender = gender;
                result.username = username;
                result.mail = mail;
                result.avatar = avatar;
                result.nickname = nickname;

                local query = "SELECT * FROM droi_account WHERE openid = '"..openid.."';";
                sync_user( query );

                return 0, result;
        else
                local insert_sql = "INSERT INTO droi_qq_user(app_id, qq_id, nickname, avatar, gender) VALUES('"..app_id.."', '"..uid.."', '"..nick.."', '"..avatar.."', '"..gender.."');";
                local res = pg:query(insert_sql);
                if res and res.affected_rows > 0 then
                else
                        pg_cleanup(pg);
                        return -10050; 
                end

                pg_cleanup(pg);

                return 0, { result = 0, forcebind = true };
        end
end

function user_regist(uid, passwd, utype, extdata)

        local pg = pg_init();

        local query, username, mail, nickname, gender, age, birthday ,device_id;

        if ( utype =="mail" ) then 
                mail = uid;
                username = "";
				device_id = ""
                query = "SELECT * FROM droi_account WHERE mail = '"..uid.."';"
        elseif ( utype=="anonym" ) then
				mail = "";
                username = "";
				device_id = uid
                query = "SELECT * FROM droi_account WHERE device_id = '"..uid.."';"
		else
                username = uid;
                mail = "";
				device_id = ""
                query = "SELECT * FROM droi_account WHERE username = '"..uid.."';"  
        end

        local res = pg:query(query);
        if res and res[1] then --user exists 
                pg_cleanup(pg);         
                return user_login( uid, passwd, utype );        --login
        end

        local passwd = passwd;
        local passwdmd5 = md5hex(passwd);

        local extdata = (type(extdata) == "table") and extdata or {}; 
        nickname = extdata.nickname or extdata.name or _TIP(1000);
	local nick = nickname:gsub("'","''");
        gender = extdata.gender or _TIP(1001);  
        age = extdata.age or 1;
        birthday = extdata.birthday or '1970-1-1';
        avatar = extdata.avatar or '';

        local insert_sql = "INSERT INTO droi_account(username, mail, passwd, passwdmd5, nickname, gender, birthday, age, avatar,device_id) VALUES('"..username.."','"..mail.."','"..passwd.."','"..passwdmd5.."','"..nick.."','"..gender.."','"..birthday.."',"..age..", '"..avatar.."','"..device_id.."') RETURNING openid;";
        
        local openid ;
        local res = pg:query(insert_sql);
	
        if res and res[1] then
		openid = delete_hyphen(res[1].openid); 
        else
	        pg_cleanup(pg);
                return -10050; 
        end


        local result = { result = 0 };  
        result.openid = openid;
        result.gender = gender;
        result.username = username;
        result.mail = mail;
        result.nickname = nickname;

        pg_cleanup(pg);

        local query = "SELECT * FROM droi_account WHERE openid = '"..openid.."';";
        sync_user( query ); 

        return 0, result;
end

function user_resetpwd_byuid(uid, passwd)
        
        local query = [[
                UPDATE droi_account SET passwd=']]..passwd..[[', passwdmd5=']]..md5hex(passwd)..[[' WHERE username =']]..uid..[[';
        ]];
        local pg = pg_init();
        local res = pg:query(query);
        if res and res.affected_rows > 0 then
                pg_cleanup(pg);

                local query = "SELECT * FROM droi_account WHERE username = '"..uid.."';";
                sync_user( query ); 

                return 0;
        end

        pg_cleanup(pg);
        return -10082;
end

---------------------below is mail--------------------------------

function user_mailstore_checkexist( mail )
        local query = [[
                SELECT * FROM droi_mailstore WHERE mail = ']]..mail..[[';
        ]];

        local pg = pg_init();

        local res = pg:query(query);
        if res and res[1] then
                pg_cleanup(pg);
                return 0, res;
        else
                pg_cleanup(pg);
                return -1;
        end
end

function user_checkexist_byid()

end

function user_get_tmp_mail_byid( mail_id )
        local pg = pg_init();

        local query =[[
                SELECT * FROM droi_mailstore WHERE mail_id = ']]..mail_id..[[';
        ]];

        local res = pg:query(query);
        if res and res[1] then
                pg_cleanup(pg); 
                return 0, res[1];
        else
                pg_cleanup(pg); 
                return -1;
        end
end

local function delete_useless_mail(mail)

        local pg = pg_init();

        local query = "DELETE FROM droi_mailstore WHERE mail ='"..mail.."';";
        local res = pg:query(query);

        if not res then
                return -10094; 
        end

        return 0;
end

function user_create_tmp_mail_account( mail, codetype, mailtheme, mailcontent, passwd, openid, app_id, device_id, request_id )

        local r = delete_useless_mail(mail);
        if r < 0 then
                return r;
        end

        local pg = pg_init(); 

        local mailtheme = mailtheme or "";
        local mailcontent = mailcontent or "";
        local passwd = passwd or "";
        local openid = openid or "";
        local app_id = app_id or "";
        local device_id = device_id or "";
        local request_id = request_id or "";

        math.randomseed(ngx.time()); 
        local rand = tostring( math.random( 100000, 999999 ) );  
        local checkno = md5hex( rand );  
        local tmp_id = rand.."randparam"; 
        local mail_id = md5hex( tmp_id );
        local expire = ngx.time() + 86400*3;

        local insert_sql = [[INSERT INTO droi_mailstore(mail, codetype, mailcontent,passwd, openid, mailtheme, mail_id, checkno, expire, app_id, device_id, request_id) VALUES(
        ']]..mail..[[',
        ']]..codetype..[[',
        ']]..mailcontent..[[',
        ']]..passwd..[[',
        ']]..openid..[[',
        ']]..mailtheme..[[',
        ']]..mail_id..[[',
        ']]..checkno..[[',
        ']]..expire..[[',
        ']]..app_id..[[',
        ']]..device_id..[[',
        ']]..request_id..[[') RETURNING token;]];

        local res = pg:query(insert_sql); 
        pg_cleanup(pg);         

        if not res or not res[1] then
                return -10093;
        end

        local token = delete_hyphen(res[1].token); 
        return 0, mail_id, checkno, expire;     
end

function user_remove_temp_mail( token )
        local pg = pg_init(); 

        local query = "DELETE FROM droi_mailstore WHERE token = '"..token.."'";
        local res = pg:query(query);
        pg_cleanup(pg); 
end

function user_mail_change_passwd(mail_id, checknumber, passwd)
        
        local code, ret = user_get_tmp_mail_byid( mail_id);
        if code < 0 then return -10100 end;
        if checknumber ~= ret.checkno then return -10101 end; 

        local mail = ret["mail"];       
        local token = ret["token"];

        local code = user_checkexist( mail, "mail" );
        if code < 0 then
                return -10010;
        end
        
        local pg = pg_init();
        local query = "UPDATE droi_account SET passwd = '"..passwd.."', passwdmd5='"..md5hex(passwd).."' WHERE mail = '"..mail.."';";
        local res = pg:query(query);
        if not res or not res.affected_rows or res.affected_rows < 1 then
                pg_cleanup(pg);
                return -10103;
        end

        pg_cleanup(pg);
        user_remove_temp_mail(token);

        local query = "SELECT * FROM droi_account WHERE mail = '"..mail.."';";
        sync_user( query ); 

        local result = {};
        result.result = 0;
        result.passwd = passwd;
        result.mail = mail;
        result.desc = _TIP(1020);
        
        return 0, result;
end

local function update_mailstore_status(mail_id)
        local pg = pg_init();
        local update_sql = "UPDATE droi_mailstore SET active = 1 WHERE mail_id= '"..mail_id.."';";
        local res = pg:query(update_sql);
        if not res or not res.affected_rows or res.affected_rows < 1 then
                pg_cleanup(pg);
                return -10102;
        end
        
        pg_cleanup(pg);
        return 0;
end

function user_bindmail(mail, openid, passwd)
        if not openid then return -10095 end
        local query = "SELECT * FROM droi_account WHERE openid ='"..openid.."';"
        local pg = pg_init();
        local res = pg:query(query);
        if not res or not res[1] then
                pg_cleanup(pg);
                return -10010;
        end

        local bind_sql;
        if res[1].passwd then
                bind_sql = "UPDATE droi_account SET mail = '"..mail.."' WHERE openid = '"..openid.."';"
        else
                bind_sql = "UPDATE droi_account SET mail = '"..mail.."', passwd = '"..passwd.."', passwdmd5 = '"..md5hex(passwd).."' WHERE openid = '"..openid.."'";
        end
        local res = pg:query(bind_sql);
        if res and res.affected_rows > 0 then
                pg_cleanup(pg);

                local query = "SELECT * FROM droi_account WHERE mail = '"..mail.."';";
                sync_user( query ); 

                return 0 , { result=0, desc = "绑定成功"};
        end

        pg_cleanup(pg);

        return -10045;
end

function user_deal_mail_request(mail_id, checknumber)

        local code, ret = user_get_tmp_mail_byid( mail_id );
        
        if code < 0 then
                return -10100;
        end
        if ret.checkno ~= checknumber then
                return -10101;
        end
        if ngx.time() > ret.expire then
                return -10104;
        end

        local rcode = 0;
        local result = {};
        if not ret.active or ret.active == 0 then
                if ret.codetype == "userreg" then
                        rcode, result = user_regist(ret.mail, ret.passwd, "mail");
                elseif ret.codetype == "bindmail" then
                        rcode, result = user_bindmail(ret.mail, ret.openid, ret.passwd);
                elseif ret.codetype == "findpasswd" then
                        rcode = 0;
                end
                if rcode ~= 0 then
                        return rcode;
                end     
        else
                result.codetype = ret.codetype;
                result.result = 0;
                return 0, result;
        end

        if ret.codetype ~= "findpasswd" then
                local rcode = update_mailstore_status(mail_id);
                if rcode < 0 then
                        return rcode;
                end
                result.mail = ret.mail;
                result.passwd = ret.passwd;
        end

        result.codetype = ret.codetype;
        result.result = 0;

        return 0, result;
end

function batch_query(list)

        local list_tab = cjson_safe.decode(list);
        if not list_tab then return -10055 end;

        local _tmp_tab = {};
        for i, v in pairs(list_tab) do
                table.insert(_tmp_tab, str_orig(v));
        end

        local cond = "'"..table.concat(_tmp_tab, "','").."'";
        local query = "SELECT openid, nickname, avatar, gender FROM droi_account WHERE openid IN("..cond..");";
        local pg = pg_init();
        local res = pg:query(query);
        local result = {};
        if res and #res >= 1 then
                result.list = {};
                for i = 1, #res do
                        local openid = str_crypt(delete_hyphen(res[i].openid));
                        result.list[openid] = {};
                        result.list[openid]["avatar"] = res[i].avatar;
                        result.list[openid]["nickname"] = res[i].nickname;
                        result.list[openid]["gender"] = res[i].gender;
                end
        else
        		result.list = {};
		end

        result.result = 0;
		pg_cleanup(pg);
        return 0 ,result;
end

----------------below is for market user sync----------------------

function sync_user( query )
        if not query then return nil end
        local pg = pg_init();
        local res = pg:query(query);
        local sql_tab = {};
        local openid;
        if res and res[1] then
                sql_tab.openid = delete_hyphen(res[1]["openid"]);
                openid = sql_tab.openid;
                sql_tab.username = res[1]["username"];
                sql_tab.mail = res[1]["mail"];
                sql_tab.passwd = res[1]["passwd"];
                sql_tab.passwdmd5 = res[1]["passwdmd5"];
                sql_tab.nickname = res[1]["nickname"];
		if sql_tab.nickname then
			sql_tab.nickname = string.gsub(sql_tab.nickname,"'","''");
		end
                sql_tab.gender = res[1]["gender"];
                sql_tab.birthday = res[1]["birthday"];
                sql_tab.weibo_id = res[1]["weibo_id"];
                sql_tab.wechat_id = res[1]["wechat_id"];
		sql_tab.device_id = res[1]["device_id"];
                sql_tab.qq_id = res[1]["qq_id"];
                sql_tab.age = res[1]["age"];
        else
                ngx.log(ngx.NOTICE,"======this query failed====="..tostring(query));
                pg_cleanup(pg);
                return;
        end

        local delete_sql = "DELETE FROM pg_sync_mongo WHERE openid = '"..openid.."';";
        local res = pg:query(delete_sql);

        local key, value = parse_key_and_values(sql_tab);
        local insert_sql = "INSERT INTO pg_sync_mongo( %s ) VALUES( %s ) RETURNING id; ";
        insert_sql = insert_sql:format( key, value );
        local res = pg:query(insert_sql);
        if res and res.affected_rows and res.affected_rows > 0 then

        else
                ngx.log(ngx.NOTICE,"======this openid insert failed====="..openid);
        end

        pg_cleanup(pg);
end

----------------above is for market user sync----------------------

