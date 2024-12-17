vim.api.nvim_create_user_command("AsyncRun", function(args)
    require("asyncrun").run_command(args.args)
end, { nargs = "*", complete = "shellcmdline" })

vim.keymap.set("n", "<Plug>AsyncRun", function()
    local cmd = require("asyncrun").get_cmd()
    vim.api.nvim_input(":AsyncRun " .. cmd)
end)
