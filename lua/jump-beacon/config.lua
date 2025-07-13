local M = {}

-- 默认配置
M.defaults = {
    enable = true,
    frequency = 8,          -- 透明度增加频率 (每次增加的百分比)
    width = 40,             -- beacon最大宽度
    timeout = 500,          -- 最大显示时间(ms)
    interval = 50,          -- 渐变间隔时间(ms)
    min_jump = 10,          -- 触发beacon的最小跳转行数
    highlight = 'ErrorMsg', -- 高亮组
    auto_enable = true,     -- 是否自动启用跳转监听
}

-- 当前配置
M.options = {}

-- 设置配置
function M.setup(opts)
    M.options = vim.tbl_deep_extend('force', M.defaults, opts or {})
end

return M
