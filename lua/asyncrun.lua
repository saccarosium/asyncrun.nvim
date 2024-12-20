local M = {}

---@class asyncrun.Request
---@field command string
---@field code number
---@field output string[]

---@type asyncrun.Request[]
local requests = {}

---@param cmd string
---@return string[]
local function cmd_build(cmd)
    local res = {}

    local shell = vim.split(vim.o.shell, " ", { trimempty = true })
    local cmdflag = vim.split(vim.o.shellcmdflag, " ", { trimempty = true })

    vim.list_extend(res, shell)
    vim.list_extend(res, cmdflag)
    table.insert(res, vim.fn.expandcmd(cmd))

    return res
end

---@param cmd string
---@return string?
local function cmd_get_compiler(cmd)
    local compilers = vim.fn.getcompletion("", "compiler")
    for _, compiler in ipairs(compilers) do
        if vim.startswith(cmd, compiler) then
            return compiler
        end
    end
end

---@param cmd string[]
local function run(cmd)
    return vim.system(cmd, { text = true }, function(obj)
        local output = {}
        local stdout = vim.split(obj.stdout, "\n", { trimempty = true })
        local stderr = vim.split(obj.stderr, "\n", { trimempty = true })

        vim.list_extend(output, stderr)
        vim.list_extend(output, stdout)

        local cmd_string = cmd[3]

        ---@type asyncrun.Request
        local request = {
            command = cmd_string,
            code = obj.code,
            output = output,
        }

        table.insert(requests, request)

        vim.schedule(function()
            vim.api.nvim_exec_autocmds("User", {
                pattern = "AsyncRunOnExit",
                data = { request = request },
            })
        end)
    end)
end

local function on_job_exit(args)
    vim.g.running_job = nil
    vim.api.nvim_del_user_command("AsyncRunAbort")

    ---@type asyncrun.Request
    local request = args.data.request
    local title = ("%s (code: %d)"):format(request.command, request.code)

    local notify = vim.schedule_wrap(vim.notify)
    if request.code == 0 then
        notify("Success: !" .. title)
    else
        notify("Failure: !" .. title, vim.log.levels.ERROR)
    end

    vim.fn.setqflist({}, "r", {
        title = title,
        lines = request.output,
        efm = vim.o.errorformat,
    })

    if not vim.tbl_isempty(request.output) then
        vim.cmd("copen | wincmd p")
    end
end

function M.get_cmd()
    local last_request = requests[#requests]
    return last_request and last_request.command or vim.o.makeprg
end

function M.run_command(cmd)
    if vim.g.running_job then
        vim.notify(("job %d is running"):format(vim.g.running_job))
        return
    end

    if vim.fn.empty(cmd) == 1 then
        return
    end

    if not vim.b.current_compiler then
        local compiler = cmd_get_compiler(cmd)
        if compiler then
            vim.cmd.compiler(compiler)
        else
            vim.o.errorformat = "%+I%.%#"
        end
    end

    local job = run(cmd_build(cmd))

    vim.g.running_job = job.pid

    vim.api.nvim_create_user_command("AsyncRunAbort", function()
        job:kill(9)
        vim.g.running_job = nil
        vim.api.nvim_del_user_command("AsyncRunAbort")
    end, { nargs = 0 })

    vim.api.nvim_create_autocmd("User", {
        pattern = "AsyncRunOnExit",
        group = vim.api.nvim_create_augroup("AsyncRun", {}),
        callback = function(args)
            on_job_exit(args)
        end,
    })
end

return M
