# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
jump-beacon.nvim is a Neovim plugin that provides visual beacon effects for cursor jumps. It's written in Lua and follows standard Neovim plugin conventions.

## Architecture

### Core Components
- **lua/jump-beacon/init.lua** - Main entry point, handles setup, autocmds, keymaps, and commands
- **lua/jump-beacon/config.lua** - Configuration management with defaults and user options merging
- **lua/jump-beacon/beacon.lua** - Core beacon rendering logic using floating windows and timers
- **plugin/jump-beacon.lua** - Plugin guard and version check

### Key Design Patterns
- **Modular Architecture**: Clear separation between configuration, beacon effects, and initialization
- **Event-driven**: Uses Neovim autocmds (CursorMoved, BufEnter) to detect large cursor jumps
- **Timer-based Animation**: Uses `vim.uv.new_timer()` for smooth fade-out effects via `winblend` property
- **Floating Window Strategy**: Creates temporary buffers with floating windows positioned at cursor location

### Critical Implementation Details
- **Position Tracking**: Maintains `last_line`/`last_col` variables to calculate jump distances
- **0-based vs 1-based Indexing**: Careful conversion between Neovim's 1-based cursor positions and 0-based buffer coordinates
- **Key Mapping Strategy**: Enhanced `<C-o>` and `<C-i>` mappings that preserve original functionality while adding beacon effects
- **Timer Management**: Proper cleanup of timers and floating windows to prevent memory leaks

## Development Commands

### Testing
No formal test suite exists. Test manually by:
- Installing in test Neovim environment
- Triggering large jumps (>10 lines) or using `<C-o>`/`<C-i>`
- Running `:JumpBeacon` command

### Linting
No automated linting configured. Follow these practices:
- Use `lua_ls` for Neovim Lua development
- Follow existing code style (Chinese comments are intentional)
- Maintain error handling with `pcall` for API calls

## Key Configuration Options
- `min_jump`: Minimum line distance to trigger beacon (default: 10)
- `frequency`: Fade speed controlling transparency increment (default: 8)
- `width`: Maximum beacon width (default: 40)
- `timeout`: Maximum display time in ms (default: 500)
- `interval`: Fade interval timing (default: 50ms)

## Common Modifications
- **New trigger conditions**: Add to `setup_autocmds()` in init.lua
- **Beacon appearance**: Modify highlight setup in beacon.lua:8-12
- **Animation behavior**: Adjust timer logic in beacon.lua:71-97
- **Key mappings**: Extend `setup_keymaps()` for additional navigation commands