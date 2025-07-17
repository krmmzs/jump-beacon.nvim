# jump-beacon.nvim

A simple Neovim plugin that adds a visual beacon effect to cursor jumps, helping you quickly locate your cursor after large movements.

## ✨ Features

- 🎯 **Visual beacon** - Red highlight that gradually fades away
- 🚀 **Auto-detection** - Automatically shows beacon on large cursor jumps
- 🖱️ **Smart mouse detection** - Ignores mouse clicks (you already know where you clicked!)
- ⌨️ **Enhanced navigation** - Adds beacon to `<C-o>` and `<C-i>` jumps
- 🎨 **Customizable** - Configure colors, timing, and trigger sensitivity
- 🪶 **Lightweight** - Minimal performance impact

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'krmmzs/jump-beacon.nvim',
    opts = {
        -- Default options (can be empty for defaults)
        enable = true,
        frequency = 8,
        min_jump = 10,
        ignore_mouse = true,  -- Don't show beacon for mouse clicks
    }
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'krmmzs/jump-beacon.nvim',
    config = function()
        require('jump-beacon').setup()
    end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'krmmzs/jump-beacon.nvim'

lua << EOF
require('jump-beacon').setup()
EOF
```

## ⚙️ Configuration

Default configuration:

```lua
require('jump-beacon').setup({
    enable = true,          -- Enable the plugin
    frequency = 8,          -- Fade speed (higher = faster fade)
    width = 40,             -- Maximum beacon width
    timeout = 500,          -- Maximum display time (ms)
    interval = 50,          -- Fade interval (ms) 
    min_jump = 10,          -- Minimum jump distance to trigger beacon
    highlight = 'ErrorMsg', -- Highlight group for beacon color
    auto_enable = true,     -- Auto-enable jump detection
    ignore_mouse = true,    -- Ignore mouse-triggered cursor movements
})
```

### Custom highlight

You can customize the beacon color by setting the `JumpBeacon` highlight group:

```lua
vim.cmd([[highlight JumpBeacon guibg=#YOUR_COLOR]])
```

## 🚀 Usage

### Automatic

The plugin automatically shows a beacon when:
- Cursor jumps more than `min_jump` lines (default: 10) via keyboard
- Using `<C-o>` (jump back) or `<C-i>` (jump forward)
- Switching between buffers

**Note:** Mouse clicks are intelligently ignored by default since you already know where you clicked!

### Manual

- `:JumpBeacon` - Show beacon at cursor position
- `:JumpBeaconToggle` - Toggle plugin on/off

### Programmatic

```lua
local beacon = require('jump-beacon')

-- Show beacon at cursor
beacon.show_at_cursor()

-- Show beacon at specific position (0-based line, column)
beacon.show(line, col, width)
```

## 🎮 Key Mappings

The plugin enhances these default mappings:

- `<C-o>` - Jump to previous location (with beacon)
- `<C-i>` - Jump to next location (with beacon)

## 🛠️ Commands

- `:JumpBeacon` - Manually trigger beacon at cursor
- `:JumpBeaconToggle` - Toggle beacon on/off

## 🖱️ Mouse Detection

By default, the plugin intelligently ignores mouse-triggered cursor movements since you already know where you clicked. This feature works across all Neovim modes (Normal, Visual, Insert, Command-line).

### Disable mouse detection

If you want the beacon to show for mouse clicks too:

```lua
require('jump-beacon').setup({
    ignore_mouse = false,  -- Show beacon for mouse clicks
})
```

### How it works

The plugin uses expression mappings to intercept mouse events and track their timestamps. When a cursor movement occurs within a short time window after a mouse click, the movement is considered mouse-triggered and the beacon is skipped.

## 🎨 Customization Examples

### Different colors

```lua
-- Red beacon (default)
vim.cmd([[highlight JumpBeacon guibg=#FF6B6B]])

-- Blue beacon  
vim.cmd([[highlight JumpBeacon guibg=#4ECDC4]])

-- Yellow beacon
vim.cmd([[highlight JumpBeacon guibg=#FFE66D]])
```

### Faster fade

```lua
require('jump-beacon').setup({
    frequency = 15,  -- Faster fade
    interval = 30,   -- More frequent updates
})
```

### More sensitive detection

```lua
require('jump-beacon').setup({
    min_jump = 5,  -- Trigger on smaller jumps
})
```

### Show beacon for mouse clicks

```lua
require('jump-beacon').setup({
    ignore_mouse = false,  -- Also show beacon for mouse clicks
    min_jump = 5,          -- More sensitive detection
})
```

## 🔧 Requirements

- Neovim 0.8.0+
- No external dependencies

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

MIT License - see [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

Inspired by:
- [lspsaga.nvim](https://github.com/nvimdev/lspsaga.nvim) - For the beacon implementation idea
- [beacon.vim](https://github.com/DanilaMihailov/beacon.nvim) - For the concept