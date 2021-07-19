local storage = require("models.storage")

local _M      = {}

function _M.add(self)
    local params                = self:json()

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
                inst_data = inst_data
            }
        }
    })
end

function _M.update(self)
    local params                = self:json()

    local inst_data, inst_error = storage.update_tr_instrument(params)
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
                inst_data = inst_data
            }
        }
    })
end

function _M.disable(self)
    local params                = self:json()

    local inst_data, inst_error = storage.disable_tr_instrument(params.uid)
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
                inst_data = inst_data
            }
        }
    })
end

function _M.enable(self)
    local params                = self:json()

    local inst_data, inst_error = storage.enable_tr_instrument(params.uid)
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
                inst_data = inst_data
            }
        }
    })
end

function _M.stat(self)
    local params                = self:json()

    local inst_data, inst_error = storage.find_tr_instrument(params.uid)
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
                inst_data = inst_data
            }
        }
    })
end

return _M