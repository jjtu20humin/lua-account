local pgmoon = require("pgmoon");
local http = require("socket.http")  
local ltn12 = require("ltn12")

function pg_init( host, port, db, user, passwd )
        local conf = {
                host = host or "10.10.50.150",
                port = port or "5432",
                database = db or "droi_account",
                user = user or "droiaccount",
                password = passwd or "vpBx*&bbOqb012%6x",
        }
        --[[
        --PG beijing
        local conf = {
                host = host or "10.10.50.95",
                port = port or "5432",
                database = db or "droi_account",
                user = user or "droiaccount",
                password = passwd or "vpBx*&bbOqb012%6x",
        }]]

        --PG SIT
--[[
        local conf = {
                host = host or "10.20.40.55",
                port = port or "40211",
                database = db or "droi_account",
                user = user or "droiaccount",
                password = passwd or "da@droi.com%0503",
        }
--]]
        local pg = pgmoon.new(conf);
        local ok, err = pg:connect();
        if not ok then
                ngx.log(ngx.NOTICE,"--------------------->"..err);
                return nil;
        end

        return pg;
end

function pg_cleanup(pg)
        pg:keepalive();
        pg = nil;
end

function delete_hyphen(str)
        return string.gsub(str,"%-","");
end

function str_crypt( str )
        local _orig_array = {
                ['a']='o',['2']='D',['c']='U',['b']='W',['e']='B',['d']='j',['g']='h',
                ['f']='3',['i']='7',['h']='Y',['k']='z',['j']='y',['m']='u',['l']='t',
                ['/']='c',['n']='J',['1']='F',['0']='s',['3']='E',['r']='e',['5']='f',
                ['t']='l',['7']='g',['v']='q',['9']='2',['8']='i',['+']='Q',['z']='b',
                ['4']='P',['o']='O',['u']='V',['s']='T',['A']='L',['p']='N',['C']='S',
                ['B']='w',['E']='K',['D']='+',['G']='p',['F']='0',['I']='4',['H']='M',
                ['K']='Z',['J']='d',['M']='k',['L']='1',['O']='6',['N']='X',['Q']='C',
                ['P']='R',['S']='H',['R']='m',['U']='9',['T']='/',['W']='8',['V']='n',
                ['Y']='5',['X']='r',['q']='G',['Z']='I',['x']='A',['w']='x',['6']='v',
                ['y']='a',[' ']='Q'};

        local _rstr = "";   --返回字符串
        if type(str) ~= "string" or #str == 0 then
                return nil;
        end

        for i=1,#str do
                local _idx = string.char(str:byte(i) );
                local _char = _orig_array[_idx];
                if not _char then
                        _char = _idx;
                end
                _rstr = _rstr .. _char ;
        end

        return _rstr;
end

function str_orig(str)
    local _crypt_array = {
        ['o']='a',['D']='2',['U']='c',['W']='b',['B']='e',['j']='d',['h']='g',
        ['3']='f',['7']='i',['Y']='h',['z']='k',['y']='j',['u']='m',['t']='l',
        ['c']='/',['J']='n',['F']='1',['s']='0',['E']='3',['e']='r',['f']='5',
        ['l']='t',['g']='7',['q']='v',['2']='9',['i']='8',['Q']='+',['b']='z',
        ['P']='4',['O']='o',['V']='u',['T']='s',['L']='A',['N']='p',['S']='C',
        ['w']='B',['K']='E',['+']='D',['p']='G',['0']='F',['4']='I',['M']='H',
        ['Z']='K',['d']='J',['k']='M',['1']='L',['6']='O',['X']='N',['C']='Q',
        ['R']='P',['H']='S',['m']='R',['9']='U',['/']='T',['8']='W',['n']='V',
        ['5']='Y',['r']='X',['G']='q',['I']='Z',['A']='x',['x']='w',['v']='6',
        ['a']='y',['Q']=' '
    }

    local _rstr = "";   --返回字符串
    if type(str) ~= "string" or #str == 0 then
            return nil;
    end

    for i=1,#str do
            local _idx = string.char(str:byte(i) );
            local _char = _crypt_array[_idx];
            if not _char then
                    _char = _idx;
            end
            _rstr = _rstr .. _char ;
    end

    return _rstr;
end

function http_GET( url )
        local response_body = {} 
        local ret, code = http.request{
                url = url,
                method = "GET",
                proxy = "http://10.10.40.2:8080/",
                sink = ltn12.sink.table(response_body),
        }
        local res = table.concat(response_body);
        return code, res
end

function http_POST( url, param, header )
        local response_body = {}  
        local post_data = param  
        local ret, code = http.request{  
                url = url,  
                method = "POST", 
                proxy = "http://10.10.40.2:8080/", 
                headers =  header,
                source = ltn12.source.string(post_data),  
                sink = ltn12.sink.table(response_body)  
        }  
        res = table.concat(response_body)  

        return code, res;
end

function parse_key_and_values( tab )
    local key = {};
    local values = "";
    for k ,v in pairs(tab) do
        table.insert(key ,k);
        v_pattern = "";
        if type(v) == "number" then
            v_pattern = tostring(v);
        else
            v_pattern = "'"..v.."'";
        end

        if values == "" then
            values = v_pattern;
        else
            values = values..","..v_pattern;
        end
    end
    return table.concat(key ,",") ,values;
end

function parse_equal_values(tab)
    local values = "";
    for k, v in pairs(tab) do
        v_pattern = "";
        if type(v) == "number" then
            v_pattern = k.."="..v;
        else
            v_pattern = k.."='"..v.."'";
        end

        if values == "" then
            values = v_pattern;
        else
            values = values..","..v_pattern;
        end
    end
    return values;
end
