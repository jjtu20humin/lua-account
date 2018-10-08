var md5_str = "ZYK_ac17c4b0bb1d5130bf8e0646ae2b4eb4";
function GetQueryString(name){
	var reg = new RegExp("(^|&)"+ name +"=([^&]*)(&|$)");
	var r = window.location.search.substr(1).match(reg);
	if(r!=null)return  unescape(r[2]); return null;
};
function check_mail_format(str){
	var mail_regexp = /^[A-Za-z\d]+([-_.][A-Za-z\d]+)*@([A-Za-z\d]+[-.])+[A-Za-z\d]{2,5}$/ ;
	return mail_regexp.test(str)
	// if(!mail_regexp.test(str)){
	// 	return false;
	// };
	// var mail_array = new Array(
	// 	/*国外常用*/
	// 	"@hotmail.com",
	// 	"@msn.com",
	// 	"@yahoo.com",
	// 	"@gmail.com",
	// 	"@aim.com",
	// 	"@aol.com",
	// 	"@mail.com",
	// 	"@walla.com",
	// 	"@inbox.com",
	// 	/*国内常用*/
	// 	"@126.com",
	// 	"@163.com",
	// 	"@sina.com",
	// 	"@21cn.com",
	// 	"@sohu.com",
	// 	"@yahoo.com.cn",
	// 	"@tom.com",
	// 	"@qq.com",
	// 	"@etang.com",
	// 	"@eyou.com",
	// 	"@56.com",
	// 	"@x.cn",
	// 	"@chinaren.com",
	// 	"@sogou.com",
	// 	"@citiz.com"
	// );
	// str = str.match("(@.+)");
	// if(null == str){
	// 	return false;
	// }else{
	// 	str = str[1];
	// };
	// str = str.replace(/\s/g,"");
	// console.log(str);
	// var mail = false;
	// for (var i = 0; i < mail_array.length; i++) {
	// 	if(mail_array[i] == str){
	// 		mail = true ;
	// 	};
	// };
	// return mail;
};
function check_moible_format(str){
	var myReg = /^(((13[0-9]{1})|(15[0-9]{1})|(18[0-9]{1})|(17[0-9]{1}))+\d{8})$/ ;
	return myReg.test(str)
};
function check_chinese_format(str){
	var myReg = /[\u4e00-\u9fa5]+/;
	return myReg.test(str);
};
function check_blank_format(str){
	var new_str = str.replace(/\s/g,"");
	return new_str!=str?true:false;
};
window.tips_time = 5;
window.clear_time = 0;
/*提示隐藏和显示*/
function tips_sleep(str ,fun){
	function tip_show(str){
		$(".cue").html(str);
		$(".cue").show();
	};
	function tip_hide(){
		$(".cue").hide();
	};
	clearTimeout(window.clear_time);
	var _times = window.tips_time ;
	// var _t = 0 ;
	function start_sleep(){
		_times -= 1 ;
		var _str = str + "...("+_times+"s)";
		if(_times >= 0){
			tip_show(_str);
			window.clear_time = setTimeout(start_sleep ,1000);
		}else{
			tip_hide();
			if( "undefined" != typeof(fun) ){fun();}
			clearTimeout(window.clear_time);
		};
	} ;
	start_sleep();
};