local storage         = require("models.storage")
local freedom_finance = require("models.freedom_finance"):new()

local _M              = {}

function _M.add(self)
    local params       = self:json()

    local order, error = freedom_finance:set_order(params)

    if error then
        return self:render({
            json = {
                result = false,
                error  = error
            }
        })
    end

    local inst_data, inst_error = storage.add_tr_instrument(params)

    if inst_error then
        return self:render({
            json = {
                result = false,
                error  = inst_error
            }
        })
    end

    return self:render({
        json = {
            result = true,
            data   = {
                order     = order,
                inst_data = inst_data
            }
        }
    })

end

function _M.update(self)

end

function _M.disable(self)

end

function _M.enable(self)

end

function _M.stat(self)

end

return _M