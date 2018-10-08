-- changepass

GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "邮件修改密码(发邮件)",
	desc = "邮件修改密码，只需要输入新密码",
	base_param = {
		{ name = "mailid", pattern = "%w+",length = {32,32}, helper = {"邮件ID","32byte md5hex值"}  },
		{ name = "checkno", pattern = "%w+",length = {32,32}, helper = {"校验码","32byte md5hex值"}  },
		{ name = "passwd", pattern = ".+", length = {4,48}, helper = {"密码","明文密码"} },
		--{ name = "sign", pattern = "%w+",length = {32,32}, helper = {"签名","32byte md5hex值"}	},
	},

	opt_param = {
	},

};

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )
	local _mail_id = _REQ['mailid'];
	local _checkno = _REQ['checkno'];
	local _passwd = _REQ['passwd'];

	local _rcode, _result = user_mail_change_passwd( _mail_id, _checkno, _passwd );
	if _rcode < 0 then return _ERR(_rcode); end

	return _result;
end;