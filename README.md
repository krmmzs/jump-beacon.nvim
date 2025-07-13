# jump-beacon.nvim

A simple Neovim plugin that adds a visual beacon effect to cursor jumps, helping you quickly locate your cursor after large movements.

## ✨ Features

- 🎯 **Visual beacon** - Red highlight that gradually fades away
- 🚀 **Auto-detection** - Automatically shows beacon on large cursor jumps
- ⌨️ **Enhanced navigation** - Adds beacon to `<C-o>` and `<C-i>` jumps
- 🎨 **Customizable** - Configure colors, timing, and trigger sensitivity
- 🪶 **Lightweight** - Minimal performance impact

## 📦 Installation

### Using [lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{
    'your-username/jump-beacon.nvim',
    config = function()
        require('jump-beacon').setup()
    end
}
```

### Using [packer.nvim](https://github.com/wbthomason/packer.nvim)

```lua
use {
    'your-username/jump-beacon.nvim',
    config = function()
        require('jump-beacon').setup()
    end
}
```

### Using [vim-plug](https://github.com/junegunn/vim-plug)

```vim
Plug 'your-username/jump-beacon.nvim'

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
- Cursor jumps more than `min_jump` lines (default: 10)
- Using `<C-o>` (jump back) or `<C-i>` (jump forward)

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