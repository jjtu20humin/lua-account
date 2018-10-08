GV_IFS = GV_IFS or {};
local _module_ = (...):match( "^.*%.(.*)$" );

GV_IFS[_module_] = {
	name = _module_,
	cname = "UI_ACTIVITY",
	base_param = {
	},

	opt_param = {
		{ name = "mailid", pattern = "%w+",length = {32,32}, helper = {"邮件ID","32byte md5hex值"}  },
		{ name = "checkno", pattern = "%w+",length = {32,32}, helper = {"校验码","32byte md5hex值"}  },
		{ name = "language", pattern = ".+", length = {1,}, helper = {"客户端语言","string"} },
	},
};

local _html_pattern = _html_pattern or get_html_pattern(_module_);

GV_IFS[_module_]['callback'] = function ( _REQ, _FILE )
	local _mail_id = _REQ['mailid'];
	local _checkno = _REQ['checkno'];
	local _language = _REQ["language"] or "en";


	local _code, _result = user_deal_mail_request(_mail_id, _checkno);
	local _htmlT = require "interface.html_pattern";
	local _pattern = GV_IFS[_module_].html_pattern or get_html_pattern(_module_);
	GV_IFS[_module_].html_pattern = _pattern;
	
	local _htmlO = _htmlT.new( db );

	local _rcode = 0;
	_result = _result or {};
	_type = _result.codetype;
	_rcode = _result.result;

	function _htmlO.TITLE() 
		if not _type then
			return _LANG(1047);
		elseif _type == "findpasswd" then
			return _LANG(1048);
		elseif _type == "bindmail" then
			return _LANG(1060);
		else
			return _LANG(1014);
		end
	end

	function _htmlO.CONTENT()
		local _communication_error = _LANG(1050);
		local _new_password = _LANG(1026);
		local _confirm_password = _LANG(1027);
		local _password_length = _LANG(1028);
		local _acachive = _LANG(1012);

		local _image = (_rcode==0) and [[<img src="/ui/droiLogin/images/success.png" />]] or [[<img src="/ui/droiLogin/images/fail.png" />]];
		local _description;
		if _type == "bindmail" then
			_description = (_rcode==0) and _LANG(1061) or (_result.desc or _communication_error);
		else
		 	_description = (_rcode==0) and _LANG(1049) or (_result.desc or _communication_error);
		end
		if _type and _type == "findpasswd" then
			local _html = [[
			  	<div class="am-panel-bd" id="passwd" >
					<form action="" class="am-form">
						<fieldset>
						<div class="am-input-group">
							<span class="am-input-group-label"><i class="am-icon-key am-icon-fw"></i></span>
							<input type="password" id="mailpwd1" class="am-form-field" placeholder="%s" required="">
						</div>
						<div class="am-input-group">
							<span class="am-input-group-label"><i class="am-icon-key am-icon-fw"></i></span>
							<input type="password" id="mailpwd2" class="am-form-field" placeholder="%s" data-equal-to="#doc-vld-pwd-1" required="">
						</div>
						<p class="corGray">%s</p>
						<button class="am-btn btn-green" type="button" id="commit">%s<tton>
						</fieldset>
					</form>				
				</div>
				 <div class="am-panel-bd success" id="other" style="display:none;">
                    <div class="picMail">%s</div>
                    <p class="corGreen" id="desc">%s</p>
                </div>
			]];
			return _html:format(_new_password ,_confirm_password ,_password_length ,_acachive ,_image ,_description);
		else
			return [[
				<div class="am-panel-bd success" id="other" >
	  				<div class="picMail">]].._image..[[</div>
	  				<p class="corGreen">]].._description..[[</p>
	  			</div>
			]];
		end	
	end

	function _htmlO.JSVAR()
		local _html = [[
			var luatext_reset_complete = %q ;
			var luatxt_ajax_error = %q ;
			var luatxt_not_match = %q ;
			var luatxt_too_long = %q ;
			var luatxt_too_short = %q ;
		]]

		return _html:format(_LANG(1056),_LANG(1034),_LANG(1057),_LANG(1059),_LANG(1058));
	end

	local _html_out = _htmlO:go( _pattern );
	return _html_out ;
end;
