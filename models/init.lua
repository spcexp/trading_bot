local fio           = require("fio")

local create_spaces = require("models.create_spaces").create

local status, _     = pcall(fio.mkdir, "tnt")
if status then
    fio.mkdir("tnt/logs")
    fio.mkdir("tnt/data")
    fio.mkdir("tnt/wal")
    fio.mkdir("tnt/mem")
end

box.cfg(app_config.box_config)
box.once("init", create_spaces())