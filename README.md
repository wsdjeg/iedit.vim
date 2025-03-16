# iedit.vim

iedit mode deteched from SpaceVim

## Installation

Use your preferred Neovim plugin manager to install mru.nvim.

with [nvim-plug](https://github.com/wsdjeg/nvim-plug)

```lua
require('plug').add({
  'wsdjeg/iedit.nvim',
  config = function()
    vim.keymap.set('n', '<leader>e', "<cmd>lua require('iedit').start()<cr>", { silent = true })
  end,
})
```

Then use `:PlugInstall iedit.nvim` to install this plugin.


