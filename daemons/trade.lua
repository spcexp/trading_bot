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

local function sellCurrentOrder()
    
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
                local quantity
                if instr.auto_calculation then
                    quantity = count_quantity()
                end
                local price         = instr.price_max - step * i
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
                    local ff_order, err        = ff:set_order(
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
                        fiber.create(function()
                            sellCurrentOrder()
                        end)
                    end
                end
            end
        end


        -- получить торгуемые интрументы
        -- запустить цикл по всем активным инструментам
        -- получить текущую цену текущего интрумента
        -- создать заявки на покупку на все возможные уровни начиная от максимальной цены
        -- (уровни рассчитываются так: (price_max - price_min) / step = количество уровней,
        -- step = 100 * step_buy_percent / max_price,
        -- 0 уровень = price_max, 1 уровень = price_max - step, 2 уровень = price_max - 2 * step
        -- level = price_max - level_number * step)
        -- если уровень освободился и цена текущая выше, то создаем новую заявку на покупку
        -- запускаем для каждой заявки файбер на продажу
        -- если все уровни заняты, то не делаем ничего
        fiber.sleep(60)
    end
end)