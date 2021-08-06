local http_client = require('http.client').new()
local log         = require('log')
local json        = require('json')
local hmac        = require("openssl").hmac
local url         = require("net.url")

local FF          = {}

function FF:new()
    local private = {}
    local public  = {}

    function private:request(url, method, cmd, params)
        local req     = {
            apiKey = app_config.ff.public_key,
            cmd    = cmd,
            nonce  = os.time(),
            params = params
        }
        local req_url = url:setQuery(req)
        local options = {
            headers = {
                ["X-NtApi-Sig"]  = private:sign(req),
                ["Content-Type"] = "application/x-www-form-urlencoded"
            }
        }

        local result
        if method == "GET" then
            result = http_client:get(url .. "?q=" .. req_url, options)
        else
            result = http_client:post(url, req_url, options)
        end

        local status, result_body = pcall(json.decode, result.body)

        if not status then
            log.error(result)
            return false
        end

        if result.status ~= 200 then
            log.warn(result.status)
            log.warn(result_body)
            return false
        end

        if not result_body.error then
            log.error(result_body)
            return false, result_body
        end

        return result_body
    end

    function private:sign(req)
        local req_prepared = private:prepare_request(req)
        return hmac.hmac('sha256', req_prepared, app_config.ff.secret_key)
    end

    function public:query_order()

    end

    function public:set_order()

    end

    function public:symbol_info()
        local req = {
            cmd    = 'putTradeOrder',
            params = {
                mode          = 'demo',
                instr_name    = "SNGSP",
                action_id     = 1,
                order_type_id = 2,
                qty           = 100,
                limit_price   = 40,
                stop_price    = 0,
                expiration_id = 3,
                userOrderId   = 146615630
            },
            apiKey = 'fca84a828afdb739dfd38db9e9640b72',
            nonce  = os.time()
        };
    end

    function private:prepare_request(req)
        local res = ""
        local first = true
        for key, value in pairs(req) do
            if not first then
                res = res .. "&"
                first = false
            end
            if type(value) == "table" then
                res = res .. key .. "=" .. private:prepare_request(value)
            else
                res = res .. key .. "=" .. value
            end
        end
        return res
    end

    setmetatable(public, self)
    self.__index = self
    return public
end

return FF
