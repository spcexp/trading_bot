#!/usr/bin/env tarantool
local queue         = require("queue")
local openapi       = require("gtn.openapi")

local queue_handler = require("modules.queue_handler")

require("modules.init")

--daemons
require("daemons.clear_requests")

local app = openapi(
        require("http.server"),
        require("http.router"),
        "openapi.yaml",
        {
            security = {},
            cors     = {},
            metrics  = app_config.metrics
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

channels = {}
queue.tube.request_queue:on_task_change(queue_handler.handler)