GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "pgtest",
	desc = "pgtest",
	base_param = {
	},

	opt_param = {
	},

};

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )

	local pg = pg_init();

	local res = pg:query("SELECT username FROM droi_account where username = '18658121531';");

--	local res = pg:query("delete from test_tb1 where key = 3;");
	--return 1 if success

--	local res = pg:query("INSERT INTO test_tb1(key, value) VALUES (2, 'bellemere') returning value;");
--	local res = pg:query("insert into uuidtest(id0) values('444') returning id0;");
	--return 1 if success

--	pg.convert_null = true
--	local res = pg:query("select NULL the_null");

--	local table_name = "test_tb1";
--	local title = "Whoii'aAaa!!";
--	local str = "update "..table_name.." set value = "..pg:escape_literal(title).." where key = 3";
--	local res = pg:query( str );
ngx.log(ngx.NOTICE,"-----------------"..type(res))
	pg_cleanup(pg);
	return {result=0, desc=cjson_safe.encode(res)}
--	return {result=0, desc=res.affected_rows};
--	return {result=0, desc=res[1].the_null};
end;
