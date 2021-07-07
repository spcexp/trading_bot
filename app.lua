#!/usr/bin/env tarantool
local openapi       = require("gtn.openapi")

require("modules.init")

local app = openapi(
        require("http.server"),
        require("http.router"),
        "openapi.yaml",
        {
            security = {},
            cors     = {}
        }
)

-- override default error responses
app:default(
        function(self, err)
            return self:render({
                status = 204,
                json   = {
                    success = false,
                    error   = err
                }
            })
        end
)

-- override request validation errors response
app:error_handler(
        function(self, err)
            return self:render({
                json = {
                    success = false,
                    error   = err
                }
            })
        end
)

-- override security errors response
app:security_error_handler(
        function(self, err)
            return self:render({
                status = 401,
                json   = {
                    error = err
                }
            })
        end
)

app:start()