--- Main entry point for jump-beacon.nvim plugin.
---
--- Purpose:
---   Provides visual beacon effects for cursor jumps in Neovim through
---   autocmd event listeners, key mappings, and manual commands.
---
--- Module Structure:
---   - Position tracking variables for detecting cursor jumps
---   - Autocmd setup for automatic beacon triggering
---   - Key mapping setup for enhanced navigation commands
---   - Command setup for manual beacon control
---   - Main setup function for plugin initialization
---
--- Architecture:
---   - Uses CursorMoved autocmd to detect large line jumps
---   - Enhances <C-o> and <C-i> mappings with beacon effects
---   - Provides :JumpBeacon and :JumpBeaconToggle commands
---   - Delegates beacon rendering to beacon module
---
--- Thread Safety:
---   - Module state is global and shared across all buffers
---   - Position tracking variables are updated synchronously
---   - Beacon effects are queued through vim.defer_fn for async execution
---
--- Example:
---   require('jump-beacon').setup({
---     min_jump = 15,
---     frequency = 12
---   })
local config = require('jump-beacon.config')
local beacon = require('jump-beacon.beacon')
local api = vim.api

local M = {}

-- Position tracking variables for jump detection
-- Initialized to line 1, column 1 (Neovim's default cursor position)
-- Note: Column tracking is maintained but not actively used in jump detection
-- since line-based jumps are the primary focus for attention management
local last_line = 1
local last_col = 1

-- Mouse event detection state
local mouse_last_clicked = 0  -- timestamp of last mouse click
local mouse_detection_window = 100  -- milliseconds window for detecting mouse events

--- Set up mouse event detection for ignoring mouse-triggered cursor movements.
---
--- Purpose:
---   Tracks mouse click events to distinguish between keyboard and mouse-triggered
---   cursor movements, allowing the plugin to ignore mouse clicks when user
---   already knows cursor position.
---
--- Implementation:
---   - Uses expression mappings to intercept mouse events
---   - Records timestamp of mouse clicks
---   - Returns original event to preserve normal mouse behavior
---   - Supports all modes: Normal, Visual, Insert, Command-line
---
--- Flow:
---   1. User clicks mouse (e.g., <LeftMouse>)
---   2. Our function is called, records mouse_last_clicked timestamp
---   3. Function returns "<LeftMouse>"
---   4. Neovim receives return value, executes original mouse click behavior
---   5. Cursor movement triggers CursorMoved event
---   6. In CursorMoved, check timestamp, detect mouse-triggered, skip beacon
---
--- Example:
---   setup_mouse_detection()
---   -- Now mouse clicks won't trigger beacon effects
local function setup_mouse_detection()
    if not config.options.ignore_mouse then
        return
    end

    -- mouse_events triggers before
    local mouse_events = {'<LeftMouse>', '<RightMouse>', '<MiddleMouse>'}
    local modes = {'n', 'v', 'i', 'c'}  -- Normal, Visual, Insert, Command-line

    for _, event in ipairs(mouse_events) do
        for _, mode in ipairs(modes) do
            vim.keymap.set(mode, event, function()
                mouse_last_clicked = vim.loop.hrtime() / 1000000  -- Convert to milliseconds
                -- expr=true mapping: return value becomes the actual key sequence to execute
                return event
            end, { buffer = false, silent = true, expr = true })
        end
    end
end

--- Check if cursor movement was triggered by mouse click.
---
--- Purpose:
---   Determines if the current cursor movement was caused by a recent mouse click
---   to avoid showing beacon when user already knows cursor position.
---
--- Returns:
---   - true: if cursor movement was mouse-triggered
---   - false: if cursor movement was keyboard-triggered
---
--- Logic:
---   - Compares current time with last recorded mouse click timestamp
---   - If within detection window, considers it mouse-triggered
---   - Only active when ignore_mouse option is enabled
local function is_mouse_triggered()
    -- neovim triggers the mouse event(LeftMouse...) first and then triggers CursorMoved,
    -- so just log the event when it is triggered and check the cursor state detection section.
    if not config.options.ignore_mouse then
        return false
    end

    local current_time = vim.loop.hrtime() / 1000000  -- Convert to milliseconds
    local time_since_mouse_click = current_time - mouse_last_clicked

    return time_since_mouse_click <= mouse_detection_window
end

local function record_cursor_pos(current_line, current_col)
    last_line = current_line
    last_col = current_col
end

--- Handle cursor movement detection and beacon triggering.
---
--- Purpose:
---   Analyzes cursor position changes to detect significant jumps
---   and triggers beacon effects for keyboard-initiated movements.
---
--- Logic:
---   - Calculates jump distance from last tracked position
---   - Ignores mouse-triggered movements if configured
---   - Shows beacon only for jumps >= min_jump threshold
---   - Updates position tracking state
local function handle_cursor_moved()
    -- State Machine: Cursor Position Tracking (Keyboard Navigation Only)
    --
    -- State = (last_line, last_col)
    -- Event: CursorMoved
    --
    --     ┌─────────────┐
    --     │    State    │
    --     │ (line, col) │
    --     └──────┬──────┘
    --            │
    --            ▼
    --     ┌─────────────┐
    --     │ CursorMoved │
    --     │    Event    │
    --     └──────┬──────┘
    --            │
    --            ▼
    --     ┌─────────────┐
    --     │   Mouse     │
    --     │  Triggered? │
    --     └──────┬──────┘
    --            │
    --      ┌─────┴─────┐
    --      │           │
    --      ▼           ▼
    --   ┌─────┐     ┌─────┐
    --   │ YES │     │ NO  │
    --   │Skip │     │Check│
    --   │Show │     │Jump │
    --   └─────┘     └─────┘
    --      │           │
    --      │           ▼
    --      │    ┌─────────────┐
    --      │    │   Check:    │
    --      │    │|new - old|  │
    --      │    │>= min_jump  │
    --      │    └──────┬──────┘
    --      │           │
    --      │     ┌─────┴─────┐
    --      │     │           │
    --      │     ▼           ▼
    --      │  ┌─────┐     ┌─────┐
    --      │  │ YES │     │ NO  │
    --      │  │Show │     │Skip │
    --      │  └─────┘     └─────┘
    --      │     │           │
    --      └─────┼─────┬─────┘
    --            │     │
    --            ▼     ▼
    --     ┌─────────────┐
    --     │Update State │
    --     │last_line =  │
    --     │current_line │
    --     └─────────────┘
    --
    local current_pos = api.nvim_win_get_cursor(0)
    local current_line = current_pos[1]
    local current_col = current_pos[2]

    -- Skip beacon if cursor movement was triggered by mouse
    if is_mouse_triggered() then
        record_cursor_pos(current_line, current_col)
        return
    end

    local jump_distance = math.abs(current_line - last_line)
    -- Only show beacon when jump distance exceeds minimum threshold
    if jump_distance >= config.options.min_jump then
        beacon.show_at_cursor()
    end

    record_cursor_pos(current_line, current_col)
end

--- Handle buffer enter event and reset position tracking.
---
--- Purpose:
---   Triggers beacon when switching to a new buffer and resets
---   position tracking to prevent false positives.
---
--- Logic:
---   - Always shows beacon when entering new buffer
---   - Updates position tracking to current cursor position
---   - No distance check needed since user needs orientation
local function handle_buffer_enter()
    -- State Machine: Buffer Switch
    --
    -- Event: BufEnter
    -- Action: Direct beacon trigger (no distance check needed)
    --
    --     ┌─────────────┐
    --     │  BufEnter   │
    --     │   Event     │
    --     └──────┬──────┘
    --            │
    --            ▼
    --     ┌─────────────┐
    --     │ Direct Show │
    --     │   Beacon    │
    --     └──────┬──────┘
    --            │
    --            ▼
    --     ┌─────────────┐
    --     │Update State │
    --     │  to new     │
    --     │  position   │
    --     └─────────────┘
    --
    beacon.show_at_cursor() -- when change buffer, show beacon directly

    local pos = api.nvim_win_get_cursor(0)
    record_cursor_pos(pos[1], pos[2])
end

--- Set up automatic beacon triggering through event listeners.
---
--- Purpose:
---   Creates autocmd group and event listeners for automatic beacon detection.
---   Delegates actual logic to dedicated handler functions.
---
--- Events:
---   - CursorMoved: Handled by handle_cursor_moved()
---   - BufEnter: Handled by handle_buffer_enter()
---
--- Example:
---   setup_automatic_detection()
---   Now cursor movements and buffer switches trigger beacon
local function setup_automatic_detection()
    local augroup = api.nvim_create_augroup('JumpBeacon', { clear = true })

    -- Listen to the CursorMoved event to check for large distance jumps
    api.nvim_create_autocmd('CursorMoved', {
        group = augroup,
        callback = handle_cursor_moved,
    })

    -- Listen to BufEnter event to reset position tracking
    api.nvim_create_autocmd('BufEnter', {
        group = augroup,
        callback = handle_buffer_enter,
    })
end

--- Set up enhanced key mappings for navigation commands with beacon effects.
---
--- Purpose:
---   Enhances standard Neovim navigation keys (<C-o>, <C-i>) with beacon
---   effects while preserving their original functionality completely.
---
--- Key Mappings:
---   - <C-o>: Jump back in jumplist with beacon effect
---   - <C-i>: Jump forward in jumplist with beacon effect
---   - <Tab>: Alternative mapping for <C-i> (terminal compatibility)
---
--- Implementation Strategy:
---   - Captures cursor position before navigation command
---   - Executes original navigation command with pcall error handling
---   - Compares positions to detect actual movement
---   - Triggers beacon only if position actually changed
---   - Uses vim.defer_fn for async beacon display
---
--- Terminal Compatibility:
---   - <C-i> often conflicts with Tab in terminal environments
---   - Provides both <C-i> and <Tab> mappings for flexibility
---   - Uses nvim_feedkeys with raw character codes to avoid recursion
---
--- Error Handling:
---   - Uses pcall to safely execute navigation commands
---   - Handles jumplist boundaries gracefully (no beacon if no movement)
---   - Prevents beacon effects when navigation fails
---
--- Example:
---   setup_keymaps()
---   -- Now <C-o> and <C-i> will show beacon when jumping
local function setup_keymaps()
    -- Enhanced <C-o> mapping with beacon effect
    -- Based on official documentation for elegant implementation
    vim.keymap.set('n', '<C-o>', function()
        local pos_before = api.nvim_win_get_cursor(0)
        -- Use official documentation recommended approach
        local ok = pcall(vim.cmd, 'execute "normal! \\<C-o>"')
        if ok then
            local pos_after = api.nvim_win_get_cursor(0)
            -- Only show beacon if position actually changed
            if pos_before[1] ~= pos_after[1] or pos_before[2] ~= pos_after[2] then
                vim.defer_fn(beacon.show_at_cursor, 10)
            end
        end
    end, { desc = 'Jump back with beacon', silent = true })

    -- <C-i> often conflicts with Tab in terminal environments
    -- Provide multiple mapping options for flexibility
    local function setup_jump_forward()
        local pos_before = api.nvim_win_get_cursor(0)

        -- Use nvim_feedkeys to send raw character, avoiding recursive mapping
        api.nvim_feedkeys('\9', 'n', false)

        -- Delay check for position change and show beacon
        vim.defer_fn(function()
            local pos_after = api.nvim_win_get_cursor(0)
            if pos_before[1] ~= pos_after[1] or pos_before[2] ~= pos_after[2] then
                beacon.show_at_cursor()
            end
        end, 20)
    end

    -- Try to map Ctrl-I
    vim.keymap.set('n', '<C-i>', setup_jump_forward, { desc = 'Jump forward with beacon', silent = true })
end

--- Set up user commands for manual beacon control.
---
--- Purpose:
---   Provides user-facing commands for manual beacon triggering
---   and runtime configuration control.
---
--- Commands:
---   - :JumpBeacon - Manually trigger beacon at current cursor position
---   - :JumpBeaconToggle - Toggle beacon functionality on/off
---
--- Command Behavior:
---   - JumpBeacon: Calls beacon.show_at_cursor() directly
---   - JumpBeaconToggle: Flips config.options.enable boolean
---   - Toggle provides user notification with current state
---
--- User Interface:
---   - Commands appear in Neovim's command completion
---   - Descriptive help text for each command
---   - Notification feedback for toggle operations
---
--- Error Handling:
---   - Commands respect current plugin configuration
---   - No error handling needed for simple boolean toggle
---   - Beacon display errors handled by beacon module
---
--- Example:
---   setup_commands()
---   -- Now :JumpBeacon and :JumpBeaconToggle are available
local function setup_commands()
    -- Manual beacon trigger command
    api.nvim_create_user_command('JumpBeacon', beacon.show_at_cursor, {
        desc = 'Show beacon at cursor position'
    })

    -- Toggle beacon functionality on/off
    api.nvim_create_user_command('JumpBeaconToggle', function()
        config.options.enable = not config.options.enable
        local status = config.options.enable and 'enabled' or 'disabled'
        vim.notify('Jump beacon ' .. status, vim.log.levels.INFO)
    end, {
        desc = 'Toggle jump beacon on/off'
    })
end

--- Main plugin setup function for jump-beacon.nvim initialization.
---
--- Purpose:
---   Initializes the plugin by setting up configuration, beacon system,
---   autocmds, key mappings, and user commands in proper order.
---
--- Parameters:
---   - opts: table|nil containing user configuration overrides
---     * See config.lua for available options and defaults
---
--- Setup Sequence:
---   1. Initialize configuration with user options
---   2. Set up beacon rendering system
---   3. Create autocmds for automatic jump detection (if auto_enable=true)
---   4. Set up enhanced key mappings for navigation commands
---   5. Create user commands for manual control
---
--- Side Effects:
---   - Modifies global plugin configuration
---   - Creates autocmd group and event listeners
---   - Registers key mappings that override default behavior
---   - Creates user commands in command namespace
---   - Initializes beacon highlight group
---
--- Error Conditions:
---   - No error handling for invalid configuration options
---   - Beacon setup errors are handled by beacon module
---   - Invalid user options are silently ignored (vim.tbl_deep_extend behavior)
---
--- Example:
---   require('jump-beacon').setup({
---     min_jump = 15,
---     frequency = 12,
---     auto_enable = true
---   })
function M.setup(opts)
    -- Initialize configuration with user options
    config.setup(opts)

    -- Initialize beacon rendering system
    beacon.setup()

    -- Set up mouse detection and automatic jump detection (if auto mode is enabled)
    if config.options.auto_enable then
        setup_mouse_detection()
        setup_automatic_detection()
    end

    -- Set up enhanced key mappings
    setup_keymaps()

    -- Set up user commands
    setup_commands()
end

--- Export main functionality for programmatic access.
---
--- Exported Functions:
---   - show: Direct access to beacon.show() function
---   - show_at_cursor: Direct access to beacon.show_at_cursor() function
---   - config: Reference to current active configuration
---
--- Usage:
---   local jump_beacon = require('jump-beacon')
---   jump_beacon.show_at_cursor()  -- Manual beacon trigger
---   print(jump_beacon.config.min_jump)  -- Access configuration
M.show = beacon.show
M.show_at_cursor = beacon.show_at_cursor
M.config = config.options

return M
