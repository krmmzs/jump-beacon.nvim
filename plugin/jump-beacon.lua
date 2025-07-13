-- jump-beacon.nvim - Beacon effect for cursor jumps
-- 防止重复加载
if vim.g.loaded_jump_beacon then
    return
end
vim.g.loaded_jump_beacon = 1

-- 检查Neovim版本
if vim.fn.has('nvim-0.8.0') == 0 then
    vim.api.nvim_err_writeln('jump-beacon.nvim requires Neovim 0.8.0+')
    return
end

-- 插件会通过require('jump-beacon').setup()进行初始化