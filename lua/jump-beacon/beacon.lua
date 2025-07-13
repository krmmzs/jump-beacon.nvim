local config = require('jump-beacon.config')
local api = vim.api
local uv = vim.uv

local M = {}

-- 设置beacon高亮
local function setup_highlight()
    vim.cmd([[
        highlight default JumpBeacon guibg=#FF6B6B guifg=NONE ctermbg=203 ctermfg=NONE
    ]])
end

-- 创建beacon效果
function M.show(line, col, width)
    local opts = config.options
    if not opts.enable then return end
    
    local current_win = api.nvim_get_current_win()
    local current_buf = api.nvim_get_current_buf()
    
    -- 确保参数有效
    line = line or 0
    col = col or 0
    width = width or opts.width
    
    -- 获取当前行内容，调整beacon宽度
    local ok, line_content = pcall(api.nvim_buf_get_lines, current_buf, line, line + 1, false)
    if ok and line_content[1] then
        width = math.min(width, math.max(#line_content[1], 10))
    end
    
    -- 创建临时缓冲区
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')
    api.nvim_buf_set_option(buf, 'filetype', 'beacon')
    
    -- 填充缓冲区内容
    local content = string.rep(' ', width)
    api.nvim_buf_set_lines(buf, 0, -1, false, { content })
    
    -- 创建浮动窗口
    local win_opts = {
        relative = 'win',
        win = current_win,
        bufpos = { line, col },
        width = width,
        height = 1,
        row = 0,
        col = 0,
        anchor = 'NW',
        focusable = false,
        noautocmd = true,
        border = 'none',
        style = 'minimal',
        zindex = 50,
    }
    
    local ok_win, winid = pcall(api.nvim_open_win, buf, false, win_opts)
    if not ok_win then
        return
    end
    
    -- 设置窗口选项
    vim.wo[winid].winblend = 0
    vim.wo[winid].winhighlight = 'Normal:JumpBeacon'
    
    -- 创建渐变效果定时器
    local timer = uv.new_timer()
    
    timer:start(0, opts.interval, vim.schedule_wrap(function()
        -- 检查窗口是否仍然有效
        if not api.nvim_win_is_valid(winid) then
            if timer and not timer:is_closing() then
                timer:stop()
                timer:close()
            end
            return
        end
        
        -- 增加透明度
        local current_blend = vim.wo[winid].winblend or 0
        local new_blend = current_blend + opts.frequency
        
        if new_blend >= 100 then
            -- 完全透明，关闭窗口
            if timer and not timer:is_closing() then
                timer:stop()
                timer:close()
            end
            if api.nvim_win_is_valid(winid) then
                pcall(api.nvim_win_close, winid, true)
            end
        else
            vim.wo[winid].winblend = new_blend
        end
    end))
    
    -- 安全保护：timeout后强制关闭
    vim.defer_fn(function()
        if timer and not timer:is_closing() then
            timer:stop()
            timer:close()
        end
        if api.nvim_win_is_valid(winid) then
            pcall(api.nvim_win_close, winid, true)
        end
    end, opts.timeout)
end

-- 在当前光标位置显示beacon
function M.show_at_cursor()
    local pos = api.nvim_win_get_cursor(0)
    local line = pos[1] - 1  -- 转换为0-based
    local col = pos[2]
    M.show(line, col)
end

-- 初始化
function M.setup()
    setup_highlight()
end

return M