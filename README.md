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
 Lua                     2          144          104           12           28
-------------------------------------------------------------------------------
 Markdown                1           36            0           26           10
 |- Lua                  1            1            1            0            0
 (Total)                             37            1           26           10
===============================================================================
 Total                   3          180          104           38           38
===============================================================================
```
