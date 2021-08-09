local http_client = require('http.client').new()
local log         = require('log')
local json        = require('json')
local hmac        = require("openssl").hmac
local url         = require("net.url")

local FF          = {}

function FF:new(mode)
    local private = {}
    local public  = {}

    private.mode = mode

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

    function public:query_order(order_id)
        local params = {
            mode        = private.mode,
            active_only = 1
        }
        local cmd = "getNotifyOrderJson"
        local url = app_config.ff.path .. "/v2/cmd/" .. cmd
        local result, error = private:request(url, "POST", cmd, params)

        if not result then
            return result, error
        end

        local order
        for _, curr_order in pairs(result.orders) do
            if curr_order.order_id == order_id then
                order = curr_order
            end
        end

        if order then
            return order
        else
            return nil, "Cannot find order"
        end
    end

    function public:set_order(symbol, action, order_type, quantity, limit_price, stop_price, expiration_id)
        local params = {
            mode          = private.mode,
            instr_name    = symbol,
            action_id     = action,
            order_type_id = order_type,
            qty           = quantity,
            limit_price   = limit_price,
            stop_price    = stop_price,
            expiration_id = expiration_id
        }
        local cmd = "putTradeOrder"
        local url = app_config.ff.path .. "/v2/cmd/" .. cmd
        return private:request(url, "POST", cmd, params)
    end
    
    function public:symbol_info(symbol)
        local params = {
            mode   = private.mode,
            ticker = symbol,
            lang   = "ru"
        }
        local cmd = "getStockData"
        local url = app_config.ff.path
        return private:request(url, "GET", cmd, params)
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
