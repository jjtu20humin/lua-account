local socket = require 'socket'

local base = _G

local function _protect(co, status, ...)
	if not status then
		local msg = ...
		if base.type(msg) == 'table' then
			return nil, msg[1]
		else
			base.error(msg, 0)
		end
	end
	if coroutine.status(co) == "suspended" then
		return _protect(co, coroutine.resume(co, coroutine.yield(...)))
	else
		return ...
	end
end

function socket.protect(f)
	return function(...)
		local co = coroutine.create(f)
		return _protect(co, coroutine.resume(co, ...))
	end
end

local smtp = require 'socket.smtp'
local ssl = require 'ssl'

local function sslCreate()
	local sock = socket.tcp()
	return setmetatable({
		connect = function(_, host, port)
			local r, e = sock:connect(host, port)
			if not r then return r, e end
			sock = ssl.wrap(sock, {mode='client', protocol='tlsv1'})
			return sock:dohandshake()
		end
 	}, {
		__index = function(t,n)
			return function(_, ...)
				return sock[n](sock, ...)
			end
		end
	})
end

function lua_send_mail(mail, title, content)

	local msg = {
		headers = {
			from = 'Droi<noreply@droi.cn>',
			to = mail,
			--subject = title,
			subject = "=?UTF-8?B?"..ngx.encode_base64(title).."?=",
			--["Content-Type"] = 'text/html; charset="UTF-8"',
			--["Subject-Type"] = 'text/plain; charset="UTF-8"',
			["Content-Type"] = 'text/html; charset="UTF-8"',
		},
		body = content
	}

	local ok, err = smtp.send({
		from = 'noreply@droi.cn',
		rcpt = mail,
		source = smtp.message(msg),
		user = 'noreply@droi.cn',
		password = 'Droi1111',
		server = '14.17.57.217',
		port = 465,
		create = sslCreate
	})

	if not ok then
    	ngx_log("fail to send mail: ===>"..err)
		return -1, err	
	end

	return 0
end

