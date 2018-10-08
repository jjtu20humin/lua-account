
config = {}
config.root_dir = "/openresty/nginx/luascript/";


----------------
config.sms = {};

config.sms = {};
config.sms["zh_CN"] = {};
config.sms["zh_CN"]["pattern"] = "您的验证码为：%s，异常请联系客服电话，如非本人操作请忽略此短信。";
config.sms["zh_CN"]["regex"] = "([0-9]{6})";

config.fileupload = {};
config.fileupload.chunksize = 8192;
config.fileupload.tmppath = "/opt";
config.fileupload.allow = { };

config.mail_link = "http://www.testaccount.com";

-----------------
config.login_expire = 86400*365;

config.app_list = {};
config.app_list["com.d.accounta"] = {
	["app_id"] = "nirumbzhR3GmDwqevVnO5wAvuwd_hBaulQAAJJMV",	
}
config.app_list["com.d.account"] = {
	["app_id"] = "mirumbzhtzjYVvl1x2av70UclfflcNTtlQAA4rIV",	
}
config.app_list["com.zy.market"] = {
    ["app_id"] = "12qumbzh7WmzuxSsfLB3cfz2Xx-niiTclQAIbjoJ",    
}
config.app_list["com.db.AccountSDK"] = {
    ["app_id"] = "jb8umbzhpmWdgNUwbv7007p90F4Y4SzTlQBtE68c",    
}
config.app_list["com.d.game"] = {
    ["app_id"] = "7rrumbzh48wpgjMDGAZkrGtkdGoOG456lQCtIAAA",    
}
config.app_list["com.zy.pay.sdkclient"] = {
    ["app_id"] = "06ovmbzhZSbGV5lyPaiokahHTAHJXD6YlQB0fCAA",    
}
