return {
    box_config = {
        readahead           = 10 * 1024 * 1024,
        vinyl_cache         = 256 * 1024 * 1024,
        wal_max_size        = 256 * 1024 * 1024,
        memtx_memory        = 1024 * 1024 * 1024,
        checkpoint_count    = 10,
        vinyl_read_threads  = 2,
        vinyl_write_threads = 4,
        force_recovery      = true,
        listen              = "/tmp/tr_bot_sps.sock",
        vinyl_dir           = "tnt/data",
        memtx_dir           = "tnt/mem",
        wal_dir             = "tnt/wal",
        log                 = "tnt/logs/prod.log",
        log_level           = 2
    },
    server_options = {
        log_requests = true,
        log_errors   = true
    },
    ff = {
        path = 'https://tradernet.com/api',
        public_key = 'fca84a828afdb739dfd38db9e9640b72',
        user_id = '1727485',
    }
}