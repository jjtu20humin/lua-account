function randcode_new(uid, codetype, randcode, step, app_id, openid, tid)
	local expire_int = expire_int or 86400*60;
	local expire = ngx.time() + expire_int;
	local tab = {
		userid = uid,
		codetype = codetype,
		randcode = randcode,
		step = step,
		expire = expire,
		app_id = app_id,
		tid = tid,
		openid = openid
	}

	local col, value = parse_key_and_values( tab );
	local query_pattern = "INSERT INTO droi_randcode( %s ) VALUES( %s ) RETURNING token;";
	local query = query_pattern:format(col, value);
	local pg = pg_init(); 
	local res = pg:query( query );
	if res and res[1] then
		local token = delete_hyphen(res[1].token);
		pg_cleanup(pg); 
		return 0, token, expire;
	else
		pg_cleanup(pg); 
		return -1;
	end
end

function oauth_session_new(unique_id, loginid, username, mail, openid, nickname, logintype, loginpass, expire, app_id)
	local username = username or "";
	local mail = mail or "";
	local nickname = nickname or "";
	local app_id = app_id or "";
	
	local nick = nickname:gsub("'","''");

	local insert_sql =[[INSERT INTO droi_oauth_session(unique_id, login_id, username, mail, openid, nickname, logintype, loginpass, expire, app_id) VALUES(
		']]..unique_id..[[',
		']]..loginid..[[',
		']]..username..[[', 
		']]..mail..[[', 
		']]..openid..[[',
		']]..nick..[[',
		']]..logintype..[[',
		']]..loginpass..[[',
		]]..expire..[[,
		']]..app_id..[[') RETURNING token;]];	
	
	local pg = pg_init();
	local res = pg:query( insert_sql );
	if res and res[1] then
		local token = delete_hyphen(res[1].token);
		pg_cleanup(pg);        
		return 0, token, expire;  
	else
		pg_cleanup(pg);
		return -1; 
	end
end

function oauth_session_get_info(token)
	local token = token;
	local sql = [[SELECT openid, unique_id, app_id FROM droi_oauth_session where token = ']]..token..[[';]]
	local pg = pg_init();
	local res = pg:query( sql );
	pg_cleanup(pg);
	if res and res[1] then
		return 0, res[1].unique_id, res[1].openid, res[1].app_id;
	else
		return -1;
	end
end

function randcode_get(token)
	local token = token;

	local pg = pg_init();

	local query = "SELECT * FROM droi_randcode WHERE token = '"..token.."';";
	local res = pg:query(query);
	if res and res[1] then
		local ret = res[1];
		pg_cleanup(pg);
		if not ret.expire or ret.expire < ngx.time() then
			return -1;
		end 
		return 0, ret;
	else
		pg_cleanup(pg);
		return -1; 
	end
end

function randcode_remove(token)
	local token = token;
	
	local pg = pg_init();
	local remove_sql = "DELETE FROM droi_randcode WHERE token = '"..token.."';";
	local res = pg:query(remove_sql);

	pg_cleanup(pg); 
end
