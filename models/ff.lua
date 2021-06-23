local http_client = require('http.client').new()
local log         = require('log')
local json        = require('json')

local FF          = {}

function FF:new()
    local private   = {}
    local public    = {}

    private.headers = {
        ['Content-Type'] = 'application/json',
        ['X-NtApi-Sig'] = ''
    }

    function private:request(link, params, headers)
        if type(headers) == 'nil' then
            headers = private.headers
        end
        local options             = {
            headers = headers
        }

        local result              = http_client:post(link, params, options)

        local status, result_body = pcall(json.decode, result.body)

        if not status or result.status ~= 200 then
            log.warn('Error: ' .. status)
            log.warn('Response status: ' .. result.status)
            log.warn('Response body: ' .. result.body)
            return false
        end

        if not result_body.Success then
            log.error('Error code: ' .. result_body.ErrorCode)
            log.error('Error message: ' .. result_body.Message)
            log.error('Error details: ' .. result_body.Details)
            return false, result_body
        end

        return result_body
    end

    function private:sign(...)

    end

    setmetatable(public, self)
    self.__index = self
    return public
end

return FF
