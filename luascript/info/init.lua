require ( "info.infolist" );

G_LANGUAGE = G_LANGUAGE or "zh_CN";

function _ERR( err_code, add_msg, ... )
	local _tmp = "";
	_tmp_a = add_msg or "";
	if GV_ERRORS[G_LANGUAGE][err_code] then
		_tmp = string.format(GV_ERRORS[G_LANGUAGE][err_code], ... );
	else
		_tmp = "ERR: "..tostring(err_code);
	end
	_tmp = _tmp.._tmp_a;
	return { result = err_code, desc = _tmp };
end

function _TIP( tip_code, add_msg, ... )
	local _tmp = "";
	_tmp_a = add_msg or "";
	if GV_TIPS[G_LANGUAGE][tip_code] then
		_tmp = string.format(GV_TIPS[G_LANGUAGE][tip_code], ...);
	else
		_tmp = "TIP: "..tostring(tip_code)
	end
	_tmp = _tmp.._tmp_a;
	return _tmp;
end

function _LANG( lang_code )
	return GV_LANG[G_LANGUAGE][lang_code];
end

