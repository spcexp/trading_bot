local fiber      = require("fiber")
local log        = require("log")

local ff         = require("models.freedom_finance"):new()
local storage    = require("models.storage")

local actions    = {
    buy         = 1,
    buy_margin  = 2,
    sell        = 3,
    sell_margin = 4
}

local order_type = {
    market     = 1,
    limit      = 1,
    stop       = 1,
    stop_limit = 1,
}

local expiration = {
    day     = 1,
    day_ext = 2,
    gtc     = 3
}

local function count_quantity()
    --TODO
end

local function sellCurrentOrder(uid, symbol_data)
    local order_buy, err = storage.find_order(uid)
    if err then
        log.error(err)
        return
    end
    local instr, err = storage.find_tr_instrument(order_buy.trin_uid)
    if err then
        log.error(err)
        return
    end

    local step            = 100 * instr.step_sell / instr.price_max
    local price           = order_buy.price + step
    local order_sell, err = storage.add_order({
        trin_uid = instr.uid,
        price    = price,
        quantity = order_buy.quantity,
        type     = "sell",
        level    = order_buy.level,
        ff_id    = nil,
        buy_uid  = order_buy.uid,
        time     = os.date("%X")
    })
    if err then
        log.error(err)
        return
    end

    local ff_order, err = ff:set_order(
            symbol_data.symbol,
            actions.sell,
            order_type.limit,
            order_buy.quantity,
            price,
            0,
            expiration.gtc
    )
    if err then
        log.error(err)
        return
    end
    local _, err = storage.set_remote_id(order_sell.uid, ff_order.order_id)
    if err then
        log.error(err)
    end
end

fiber.create(function()
    while true do
        local instrs = box.space.tr_instrument.index.active:select { true }
        for _, instr in pairs(instrs) do
            local symbol_data = box.space.symbol_book.index.symbol:get(instr.tirb_uid)
            local step        = 100 * instr.step_buy / instr.price_max
            local steps_count = (instr.price_max - instr.price_min) / step
            local quantity    = instr.buy_one_step
            for i = 1, steps_count do
                if instr.auto_calculation then
                    quantity = count_quantity()
                end
                local price              = instr.price_max - step * i
                local storage_order, err = storage.add_order({
                    trin_uid = instr.uid,
                    price    = price,
                    quantity = quantity,
                    type     = "buy",
                    level    = i,
                    ff_id    = nil,
                    buy_uid  = nil,
                    time     = os.date("%X")
                })
                if not storage_order then
                    log.error(err)
                else
                    local ff_order, err = ff:set_order(
                            symbol_data.symbol,
                            actions.buy,
                            order_type.limit,
                            quantity,
                            price,
                            0,
                            expiration.gtc
                    )
                    if err ~= nil then
                        log.error(err)
                    else
                        local _, err = storage.set_remote_id(storage_order.uid, ff_order.order_id)
                        if err then
                            log.error(err)
                        end
                        sellCurrentOrder(storage_order.uid, symbol_data)
                    end
                end
            end
        end
        fiber.sleep(60)
    end
end)