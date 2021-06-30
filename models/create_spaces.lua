local schema = {
    tr_instrument_ref_book = {
        { name = "uid",  type = "uuid",   is_nullable = false },
        { name = "name", type = "string", is_nullable = false },
        { name = "data", type = "map",    is_nullable = false }
    },
    tr_instrument          = {
        { name = "uid",              type = "uuid",     is_nullable = false },
        { name = "tirb_uid",         type = "uuid",     is_nullable = false },
        { name = "deposit",          type = "decimal",  is_nullable = false },
        { name = "price_min",        type = "decimal",  is_nullable = false },
        { name = "price_max",        type = "decimal",  is_nullable = false },
        { name = "auto_calculation", type = "boolean",  is_nullable = false },
        { name = "buy_one_step",     type = "unsigned", is_nullable = false },
        { name = "with_margin",      type = "boolean",  is_nullable = false },
        { name = "step_buy",         type = "decimal",  is_nullable = false },
        { name = "step_sell",        type = "decimal",  is_nullable = false },
        { name = "buy_always",       type = "boolean",  is_nullable = false },
        { name = "date_start",       type = "string",   is_nullable = false },
        { name = "date_end",         type = "string",   is_nullable = false },
        { name = "active",           type = "boolean",  is_nullable = false }
    },
    orders                 = {
        { name = "uid",      type = "uuid",    is_nullable = false },
        { name = "tiiw_uid", type = "uuid",    is_nullable = false },
        { name = "price",    type = "decimal", is_nullable = false },
        { name = "type",     type = "string",  is_nullable = false }, -- buy/sell
        { name = "buy_uid",  type = "uid",     is_nullable = false },
        { name = "time",     type = "string",  is_nullable = false }
    }
}

local _M     = {}

function _M.create()
    local tr_instrument_ref_book = box.schema.create_space("tr_instrument_ref_book", { engine = "vinyl", format = schema.tr_instrument_ref_book })
    local tr_instrument          = box.schema.create_space("tr_instrument",          { engine = "vinyl", format = schema.tr_instrument })
    local orders                 = box.schema.create_space("orders",                 { engine = "vinyl", format = schema.orders })

    tr_instrument_ref_book:create_index("uid")
    tr_instrument:create_index("uid")
    orders:create_index("uid")

    tr_instrument_ref_book:create_index("name", { type = "tree", parts = { 2, "string" }, unique = false })

    tr_instrument:create_index("tirb_uid",         { type = "tree", parts = { 2, "uuid" },     unique = false })
    tr_instrument:create_index("auto_calculation", { type = "tree", parts = { 6, "boolean" },  unique = false })
    tr_instrument:create_index("with_margin",      { type = "tree", parts = { 8, "boolean" },  unique = false })
    tr_instrument:create_index("buy_always",       { type = "tree", parts = { 11, "boolean" }, unique = false })
    tr_instrument:create_index("active",           { type = "tree", parts = { 14, "boolean" }, unique = false })

    orders:create_index("tiiw_uid", { type = "tree", parts = { 2, "uuid" },   unique = false })
    orders:create_index("type",     { type = "tree", parts = { 4, "string" }, unique = false })
    orders:create_index("buy_uid",  { type = "tree", parts = { 5, "uuid" },   unique = false })
    orders:create_index("time",     { type = "tree", parts = { 6, "string" }, unique = false })

    box.schema.user.grant("guest", "read,write,execute", "universe")
end

return _M