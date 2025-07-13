local config = require('jump-beacon.config')
local beacon = require('jump-beacon.beacon')
local api = vim.api

local M = {}

-- 跟踪上次光标位置
local last_line = 1
local last_col = 0

-- 设置autocmd来监听跳转
local function setup_autocmds()
    local augroup = api.nvim_create_augroup('JumpBeacon', { clear = true })

    -- 监听CursorMoved事件，检查大距离跳转
    api.nvim_create_autocmd('CursorMoved', {
        group = augroup,
        callback = function()
            local current_pos = api.nvim_win_get_cursor(0)
            local current_line = current_pos[1]
            local current_col = current_pos[2]

            local jump_distance = math.abs(current_line - last_line)

            -- 只有跳转距离大于配置的最小跳转距离时才显示beacon
            if jump_distance >= config.options.min_jump then
                beacon.show_at_cursor()
            end

            last_line = current_line
            last_col = current_col
        end,
    })

    -- 监听BufEnter事件，重置位置跟踪
    api.nvim_create_autocmd('BufEnter', {
        group = augroup,
        callback = function()
            local pos = api.nvim_win_get_cursor(0)
            last_line = pos[1]
            last_col = pos[2]
        end,
    })
end

-- 设置按键映射
local function setup_keymaps()
    -- 重写ctrl-o和ctrl-i，在原功能基础上添加beacon
    vim.keymap.set('n', '<C-o>', function()
        -- 保存位置并执行跳转
        local pos_before = api.nvim_win_get_cursor(0)
        pcall(vim.cmd, 'normal! \15')  -- \15 是 Ctrl-O
        local pos_after = api.nvim_win_get_cursor(0)
        -- 只有位置真的变化了才显示beacon
        if pos_before[1] ~= pos_after[1] or pos_before[2] ~= pos_after[2] then
            vim.defer_fn(beacon.show_at_cursor, 10)
        end
    end, { desc = 'Jump back with beacon', silent = true })

    vim.keymap.set('n', '<C-i>', function()
        -- 保存位置并执行跳转
        local pos_before = api.nvim_win_get_cursor(0)
        pcall(vim.cmd, 'normal! \9')   -- \9 是 Ctrl-I (Tab)
        local pos_after = api.nvim_win_get_cursor(0)
        -- 只有位置真的变化了才显示beacon
        if pos_before[1] ~= pos_after[1] or pos_before[2] ~= pos_after[2] then
            vim.defer_fn(beacon.show_at_cursor, 10)
        end
    end, { desc = 'Jump forward with beacon', silent = true })
end

-- 设置命令
local function setup_commands()
    -- 手动触发beacon
    api.nvim_create_user_command('JumpBeacon', beacon.show_at_cursor, {
        desc = 'Show beacon at cursor position'
    })

    -- 切换beacon开关
    api.nvim_create_user_command('JumpBeaconToggle', function()
        config.options.enable = not config.options.enable
        local status = config.options.enable and 'enabled' or 'disabled'
        vim.notify('Jump beacon ' .. status, vim.log.levels.INFO)
    end, {
        desc = 'Toggle jump beacon on/off'
    })
end

-- 插件主设置函数
function M.setup(opts)
    -- 设置配置
    config.setup(opts)

    -- 初始化beacon
    beacon.setup()

    -- 设置autocmds（如果启用了自动模式）
    if config.options.auto_enable then
        setup_autocmds()
    end

    -- 设置按键映射
    setup_keymaps()

    -- 设置命令
    setup_commands()
end

-- 导出主要功能
M.show = beacon.show
M.show_at_cursor = beacon.show_at_cursor
M.config = config.options

return M
