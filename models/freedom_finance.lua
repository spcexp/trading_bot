local http_client = require('http.client').new()
local log         = require('log')
local json        = require('json')

local FF          = {}

function FF:new()
    local private   = {}
    local public    = {}

    function private:request()

    end

    function private:sign(...)

    end

    function public:query_order()

    end

    function public:set_order()

    end

    function public:symbol_info()
        
    end

    setmetatable(public, self)
    self.__index = self
    return public
end

return FF
