function app_check( package_name, app_id )
	--local query = "SELECT * FROM app WHERE package_name = '"..package_name.."' and app_id = '"..app_id.."';";
	local query = "SELECT * FROM app WHERE app_id = '"..app_id.."';";

        local pg = pg_init();
        local res = pg:query(query);
        pg_cleanup(pg); 
        if res and res[1] then
            return 0;               --exists
        end
        return -100000;                      --not exists
	-- if not config.app_list[package_name] then return -100000 end
	-- if config.app_list[package_name]["app_id"] ~= app_id then return -100001 end

end

function app_get_auth( app_id )
	local query = "SELECT * FROM app WHERE app_id = '"..app_id.."';";

    local pg = pg_init();
    local res = pg:query(query);
    pg_cleanup(pg); 
    if res and res[1] then
        return 0,res[1];               --exists
    end
    return -100000;                      --not exists
end

function app_upsert( package_name, app_id )
	local query = "SELECT * FROM app WHERE app_id = '"..app_id.."';";

    local pg = pg_init();
    local res = pg:query(query);
    if res and res[1] then
        local update_sql = "UPDATE app SET package_name = '"..package_name.."' WHERE app_id = '"..app_id.."';"
        local res = pg:query(update_sql);
        if res and res.affected_rows > 0 then
            pg_cleanup(pg);
            return 0
        end
        return -1001
    end

    local now = ngx.time()
    local insert_sql = "INSERT INTO app(app_id, package_name, status) VALUES('"..app_id.."', '"..package_name.."',  1 );"
    local res = pg:query(insert_sql);
    pg_cleanup(pg);

    return 0;
end
