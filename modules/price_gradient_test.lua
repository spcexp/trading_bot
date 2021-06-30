local log       = require("log")
local fiber     = require("fiber")

--local total     = 20000
--local step      = 0.1
--local max_price = 72
--local min_price = 69

local total     = 10
local step      = 1
local max_price = 10
local min_price = 5

log.info("total = " .. total)
log.info("step = " .. step)
log.info("max_price = " .. max_price)
log.info("min_price = " .. min_price)

--local count_of_steps = (max_price - min_price) / step
--log.info("count_of_steps = " .. count_of_steps)

local price_and_factor = {}
local factor           = 1
for price = max_price, min_price, (-1) * step do
    --log.info("current price = " .. price)
    table.insert(price_and_factor, factor, { price = price, factor = factor })
    factor = factor + 1
end
log.info(price_and_factor)

local current_summ = 0
for _, pf in pairs(price_and_factor) do
    current_summ = current_summ + pf.price * pf.factor
end
log.info(current_summ)

if current_summ > total then
    local max_factor        = factor - 1
    local current_max_price = max_price
    local diff              = current_summ - total
    log.info(diff)
    local correction     = 0
    local current_factor = max_factor
    local last_price
    while diff > correction do
        log.info(max_factor)
        if max_factor > 1 then
            for key, pf in pairs(price_and_factor) do
                if
                        pf.factor == current_factor and
                        last_price ~= pf.price and
                        pf.factor ~= 1
                then
                    correction            = correction + pf.price
                    price_and_factor[key] = { price = pf.price, factor = pf.factor - 1 }
                    last_price            = pf.price
                    current_factor        = current_factor - 1
                    log.info(correction)
                end
                if diff <= correction then break; end
            end
        else
            for key, pf in pairs(price_and_factor) do
                if current_max_price == pf.price and pf.factor > 0 then
                    correction            = correction + pf.price
                    price_and_factor[key] = { price = pf.price, factor = pf.factor - 1 }
                    current_max_price     = pf.price - step
                    log.info(correction)
                end
                if diff <= correction then break; end
            end
        end

        if current_factor == 1 then
            max_factor     = max_factor - 1
            current_factor = max_factor
        end
        fiber.sleep(1)
    end
else

end
log.info(price_and_factor)

current_summ = 0
for _, pf in pairs(price_and_factor) do
    current_summ = current_summ + pf.price * pf.factor
end
log.info(current_summ)