--- Configuration management for jump-beacon.nvim plugin.
---
--- Purpose:
---   Provides centralized configuration management with default values,
---   user option merging, and validation for the jump-beacon plugin.
---
--- Module Structure:
---   - defaults: table containing all default configuration values
---   - options: table containing current active configuration (merged defaults + user opts)
---   - setup(opts): function to initialize configuration with user overrides
---
--- Configuration Properties:
---   - enable: boolean controlling global plugin activation
---   - frequency: number (1-100) controlling transparency increment rate per animation frame
---   - width: number (1-200) defining maximum beacon width in characters
---   - timeout: number (100-2000) setting maximum display duration in milliseconds
---   - interval: number (10-200) controlling animation frame interval in milliseconds
---   - min_jump: number (1-50) defining minimum line jump distance to trigger beacon
---   - highlight: string specifying Neovim highlight group name for beacon appearance
---   - auto_enable: boolean controlling automatic event listener setup
---   - ignore_mouse: boolean controlling whether to ignore mouse-triggered cursor movements
---
--- Thread Safety:
---   - Module state is global and shared across all plugin instances
---   - Configuration should be set once during plugin initialization
---   - Not safe for concurrent modification during runtime
---
--- Example:
---   local config = require('jump-beacon.config')
---   config.setup({
---     frequency = 12,
---     width = 60,
---     min_jump = 15
---   })
---   print(config.options.frequency) -- outputs: 12
local M = {}

-- Default configuration
M.defaults = {
    enable = true,
    frequency = 8, -- frequency of transparency increase (percentage per increase)
    width = 40, -- maximum width of beacon
    timeout = 500, -- maximum display time (ms)
    interval = 50, -- fading interval (ms)
    min_jump = 10, -- minimum number of rows to jump to trigger beacon
    highlight = 'ErrorMsg', -- highlight group
    auto_enable = true, -- whether to automatically enable the jump listener
    ignore_mouse = true, -- ignore mouse-triggered cursor movements (user knows position when clicking)
}

-- Current configuration
M.options = {}

--- Initialize configuration by merging user options with defaults.
---
--- Purpose:
---   Merges user-provided configuration options with default values using
---   deep extend to preserve nested table structures and type safety.
---
--- Parameters:
---   - opts: table|nil containing user configuration overrides
---     * enable: boolean - global plugin activation state
---     * frequency: number - transparency increment rate (1-100)
---     * width: number - maximum beacon width in characters (1-200)
---     * timeout: number - maximum display duration in ms (100-2000)
---     * interval: number - animation frame interval in ms (10-200)
---     * min_jump: number - minimum jump distance to trigger beacon (1-50)
---     * highlight: string - Neovim highlight group name
---     * auto_enable: boolean - automatic event listener setup
---     * ignore_mouse: boolean - ignore mouse-triggered cursor movements
---
--- Postconditions:
---   - M.options table is populated with merged configuration
---   - All default values are preserved for unspecified user options
---   - User values override corresponding default values
---   - Nested tables are properly merged (deep extend behavior)
---
--- Side Effects:
---   - Modifies module-level M.options table
---   - No validation performed on input values
---   - Previous M.options content is completely replaced
---
--- Example:
---   -- Basic setup with some overrides
---   M.setup({
---     frequency = 12,
---     width = 60
---   })
---   -- M.options.frequency == 12, M.options.width == 60
---   -- All other values remain as defaults
---
---   -- Setup with nil (uses all defaults)
---   M.setup(nil)
---   -- M.options contains exact copy of M.defaults
function M.setup(opts)
    M.options = vim.tbl_deep_extend('force', M.defaults, opts or {})
end

return M
