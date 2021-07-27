local ff      = require("models.freedom_finance"):new()

local log     = require("log")
local uuid    = require("uuid")

local storage = {}

function storage.find_symbol_book_by_symbol(symbol)
    local symbol_data = box.space.symbol_book.index.name:get(symbol)

    if not symbol_data then
        log.warn("Dont find symbol data for " .. symbol)
        return nil, "Dont find symbol data for " .. symbol
    end

    return symbol_data
end

function storage.add_symbol_book(symbol)
    local symbol_data, err = ff:symbol_info(symbol)
    if err ~= nil then
        return nil, err
    end

    local data       = {
        uid    = uuid.new(),
        symbol = symbol,
        data   = symbol_data
    }

    local tuple, err = box.space.symbol_book:frommap(data)
    if err then
        return nil, err
    end
    local insert_result = box.space.symbol_book:insert(tuple)
    return insert_result:tomap({ names_only = true })
end

function storage.add_tr_instrument(params)
    local symbol_data, err = storage.find_symbol_book_by_symbol(params.symbol)
    if err ~= nil then
        symbol_data, err = storage.add_symbol_book(params.symbol)
        if err ~= nil then
            return nil, err
        end
    end

    local data       = {
        uid              = uuid.new(),
        tirb_uid         = symbol_data.uid,
        deposit          = params.deposit,
        price_min        = params.price_min,
        price_max        = params.price_max,
        auto_calculation = params.auto_calculation,
        buy_one_step     = params.buy_one_step and params.buy_one_step or 1,
        with_margin      = params.with_margin and params.with_margin or false,
        step_buy         = params.step_buy,
        step_sell        = params.step_sell,
        buy_always       = params.buy_always and params.buy_always or true,
        date_start       = params.date_start and params.date_start or os.date("%Y-%m-%d"),
        date_end         = params.date_end and params.date_end or "",
        active           = params.active
    }

    local tuple, err = box.space.tr_instrument:frommap(data)
    if err then
        return nil, err
    end
    local insert_result = box.space.tr_instrument:insert(tuple)
    return insert_result:tomap({ names_only = true })
end

function storage.update_tr_instrument(params)
    local _, err = storage.find_tr_instrument(params.uid)
    if err ~= nil then
        return nil, err
    end

    local symbol_data, err = storage.find_symbol_book_by_symbol(params.symbol)
    if err ~= nil then
        symbol_data, err = storage.add_symbol_book(params.symbol)
        if err ~= nil then
            return nil, err
        end
    end

    local update_result = box.space.tr_instrument:update({
        params.uid,
        { "=", 2, symbol_data.uid },
        { "=", 3, params.deposit },
        { "=", 4, params.price_min },
        { "=", 5, params.price_max },
        { "=", 6, params.auto_calculation },
        { "=", 7, params.buy_one_step },
        { "=", 8, params.with_margin },
        { "=", 9, params.step_buy },
        { "=", 10, params.step_sell },
        { "=", 11, params.buy_always },
        { "=", 12, params.date_start },
        { "=", 13, params.date_end },
        { "=", 14, params.active },
    })
    return update_result:tomap({ names_only = true })
end

function storage.find_tr_instrument(uid)
    local instrument_data = box.space.tr_instrument:get(uid)

    if not instrument_data then
        log.warn("Dont find instrument data for " .. uid)
        return nil, "Dont find instrument data for " .. uid
    end

    return instrument_data
end

function storage.disable_tr_instrument(uid)
    local _, err = storage.find_tr_instrument(uid)
    if err ~= nil then
        return nil, err
    end

    local update_result = box.space.tr_instrument:update({
        uid,
        { "=", 14, false },
    })
    return update_result:tomap({ names_only = true })
end

function storage.enable_tr_instrument(uid)
    local _, err = storage.find_tr_instrument(uid)
    if err ~= nil then
        return nil, err
    end

    local update_result = box.space.tr_instrument:update({
        uid,
        { "=", 14, true },
    })
    return update_result:tomap({ names_only = true })
end

function storage.add_order(params)
    local exist = storage.is_order_exist(params.trin_uid, params.level)
    if exist then
        return nil, 'Order already exist'
    end

    local data       = {
        uid      = uuid.new(),
        trin_uid = params.trin_uid,
        price    = params.price,
        quantity = params.quantity,
        type     = params.type,
        level    = params.level,
        ff_id    = params.ff_id,
        buy_uid  = params.buy_uid,
        time     = params.time,
        status   = nil
    }

    local tuple, err = box.space.orders:frommap(data)
    if err then
        return nil, err
    end
    local insert_result = box.space.orders:insert(tuple)
    return insert_result:tomap({ names_only = true })
end

function storage.set_remote_id(uid, remote_id)
    local _, err = storage.find_order(uid)
    if err then
        return nil, err
    end

    local update_result = box.space.order:update({
        uid,
        { "=", 7, remote_id }
    })
    return update_result:tomap({ names_only = true })
end

function storage.find_order(uid)
    local order = box.space.order:get(uid)

    if not order then
        log.warn("Dont find order data for " .. uid)
        return nil, "Dont find order data for " .. uid
    end

    return order
end

function storage.is_order_exist(trin_uid, level)
    local statuses = {"1", "10", "11", "12", "20", "21"}
    for _, status in pairs(statuses) do
        local order = box.space.order.index.uniq:get(trin_uid, level, status)
        if order then
            return true
        end
    end

    return false
end

function storage.set_order_status(uid, status)
    local _, err = storage.find_order(uid)
    if err then
        return nil, err
    end

    local update_result = box.space.order:update({
        uid,
        { "=", 10, status }
    })
    return update_result:tomap({ names_only = true })
end

return storage