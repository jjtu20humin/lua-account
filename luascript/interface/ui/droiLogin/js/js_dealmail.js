function tip_show(str){
	$(".cue").html(str);
	$(".cue").show();
};
function tip_hide(){
	$(".cue").hide();
};

function GetQueryString(name){
    var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
    var r = window.location.search.substr(1).match(reg);
    if(r!=null)return  unescape(r[2]); return null;
};

resetpwd = function(_mailid, _checkno, _passwd){
	var _ajax_pattern = {
		type : "POST",
		url : '/oauth/mailchangepass',
		data: {
			mailid: _mailid,
			checkno: _checkno,
			passwd: _passwd,
		},
		success: function(data) {
			var _data = JSON.parse(data);
			if(_data.result == 0 ){
				window._ajax_result = 0 ;
				//window.DroiAccountSDK.onLoginResult(JSON.stringify(data));
			}else{
				window._ajax_result = -1 ;
				//window.DroiAccountSDK.onLoginResult(JSON.stringify(data));
			};
		},
		error: function(data) {
			console.log(data);
			window._ajax_result = -2;
			//window.DroiAccountSDK.onLoginResult(JSON.stringify({result:-408 ,desc:"网络错误!"}));
		},
	};
	$.ajax(_ajax_pattern);
};

function sleep(sec ,fun){
    var _count = sec ;
    var _t = 0 ;
    var _tmp = 0 ;
    function timedCount(){
        _count = _count - 1 ;
        if(_count >= 0 ){
            _t = setTimeout(timedCount ,1000);
            if( 0 == window._ajax_result || -1 == window._ajax_result){
                fun();
                _tmp = 1;
                clearTimeout(_t);
                return;
            };
        }else{
            if( 0 == _tmp ){
                fun();
            };

            clearTimeout(_t);
        };
    };
    timedCount();
};

function wait_ajax(){
	if( 0 == window._ajax_result){
		$("#passwd").css("display","none");
		$("#desc").html(luatext_reset_complete);
		$("#other").css("display","block");
	}else if( -1 == window._ajax_result ){

	}else if( -2 == window._ajax_result){
		tip_show(luatxt_ajax_error);
		common_sleep(5 ,tip_hide);
	};
};

$("#commit").click(function(){
	var _pwd1 = $("#mailpwd1").val();
	var _pwd2 = $("#mailpwd2").val();
	if (_pwd1 != _pwd2){
		tip_show(luatxt_not_match);
		common_sleep(5 ,tip_hide );
		return; 
	};
	var _pwd = _pwd1;
	if (_pwd.length < 6){
		tip_show(luatxt_too_short);
		common_sleep(5 ,tip_hide );
		return ;
	};
	if (_pwd.length > 12){
		tip_show(luatxt_too_long);
		common_sleep(5 ,tip_hide ); 
		return ;
	};
	resetpwd(mailid, checkno, _pwd);
	sleep(10, wait_ajax);
	return;
});

function common_sleep(times ,fun ,other){
	var _times = times ;
	var _t = 0 ;
	function start_sleep(){
		_times -= 1 ;
		if(_times >= 0){
			_t = setTimeout(start_sleep ,1000);
		}else{
			fun();
			if("function" == typeof(other)){
				other();
			};
			clearTimeout(_t);
		};
	} ;
	start_sleep();
};

var mailid = GetQueryString("mailid");
var checkno = GetQueryString("checkno"); 
