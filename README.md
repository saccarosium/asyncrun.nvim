# AsyncRun.nvim

Super minimal vim-dispatch alternative

## Features

Async Run provides:
- `AsyncRun` command
- `<Plug>AsyncRun`

## Setup

Map `<Plug>AsyncRun` to your prefer key:

```lua
vim.keymap.set("n", "<leader>;", "<Plug>AsyncRun")
```

This will populate the commandline with `:AsyncRun <last runned command or makeprg>`

## FAQ

### How minimal is it?

```
===============================================================================
 Language            Files        Lines         Code     Comments       Blanks
===============================================================================
 Lua                     2          116           95            0           21
-------------------------------------------------------------------------------
 Markdown                1           25            0           15           10
 |- Lua                  1            1            1            0            0
 (Total)                             26            1           15           10
===============================================================================
 Total                   3          141           95           15           31
===============================================================================
```
