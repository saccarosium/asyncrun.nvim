local M = {}

local requests = {}

local function run(cmd)
    local lines = {}

    local on_output = function(_, data, _)
        for _, line in ipairs(data) do
            if vim.fn.empty(line) ~= 1 then
                table.insert(lines, line)
            end
        end
    end

    local on_exit = function(id, code, _)
        local title = ("%s (job/%d)"):format(cmd, id)

        if code == 0 then
            vim.notify("Success: !" .. title)
        else
            vim.notify("Failure: !" .. title, vim.log.levels.ERROR)
        end

        vim.fn.setqflist({}, "r", {
            title = title,
            lines = lines,
            efm = vim.o.errorformat,
        })

        vim.g.running_job = nil

        table.insert(requests, {
            id = id,
            did_output = not vim.tbl_isempty(lines),
            command = cmd,
            code = code,
        })

        vim.api.nvim_exec_autocmds("QuickfixCmdPost", {
            pattern = "async_make",
        })
    end

    vim.g.running_job = vim.fn.jobstart(cmd, {
        on_stderr = on_output,
        on_stdout = on_output,
        on_exit = on_exit,
        stdout_buffered = true,
        stderr_buffered = true,
    })
end

local function get_compiler_for(cmd)
    local compilers = vim.fn.getcompletion("", "compiler")
    for _, compiler in ipairs(compilers) do
        if vim.startswith(cmd, compiler) then
            return compiler
        end
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

    cmd = vim.fn.expandcmd(cmd)

    if not vim.b.current_compiler then
        local compiler = get_compiler_for(cmd)
        if compiler then
            vim.cmd.compiler(compiler)
        else
            vim.o.errorformat = "%+I%.%#"
        end
    end

    run(cmd)

    vim.api.nvim_create_autocmd("QuickfixCmdPost", {
        once = true,
        pattern = "async_make",
        callback = function()
            local request = requests[#requests]
            if request and request.did_output then
                vim.cmd("copen | wincmd p")
            end

            vim.api.nvim_create_autocmd("CursorMoved", {
                once = true,
                command = "cclose",
            })
        end,
    })
end

return M
