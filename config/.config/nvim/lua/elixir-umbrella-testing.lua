-- Function to create a floating window
local function open_floating_window()
    local width = vim.o.columns
    local height = vim.o.lines

    -- Window dimensions
    local win_height = math.floor(height * 0.8)
    local win_width = math.floor(width * 0.8)
    local row = math.floor((height - win_height) / 2)
    local col = math.floor((width - win_width) / 2)

    -- Buffer options
    local buf = vim.api.nvim_create_buf(false, true) -- Create a new empty buffer
    local win = vim.api.nvim_open_win(buf, true, {
        relative = 'editor',
        width = win_width,
        height = win_height,
        row = row,
        col = col,
        style = 'minimal'
    })

    -- Set some buffer local options
    vim.api.nvim_buf_set_option(buf, 'bufhidden', 'wipe')

    return buf, win
end

-- elixir umbrella app testing
MixCommand = "MIX_ENV=test mix cmd"
MixTest = "mix test"
ExtraOptions = "--trace --color"

local function get_app_name(current_file)
  local app_name = string.match(current_file, "apps/(.-)/")
  return app_name
end

local all_tests_command = function ()
  local command = MixCommand .. " " .. MixTest .. " " .. ExtraOptions
  return command
end

local app_tests_command= function ()
  local app_name = get_app_name(vim.fn.expand('%'))
  local command = MixCommand .. " --app " .. app_name .. " " .. MixTest .. " " .. ExtraOptions
  return command
end

local file_tests_command = function ()
  local current_file = vim.fn.expand('%')
  -- check if the file is a test file
  if not string.match(current_file, "_test.exs$") then
    print("This is not a test file")
    return false
  end
  local app_name = get_app_name(current_file)
  local test_file = current_file:match(app_name .. "/(test/.*)")
  local command = MixCommand .. " --app " .. app_name .. " " .. MixTest .. " " .. test_file .. " " .. ExtraOptions
  return command
end

local current_test_command = function ()
  local current_file = vim.fn.expand('%')
  -- check if the file is a test file
  if not string.match(current_file, "_test.exs$") then
    print("This is not a test file")
    return false
  end
  local current_line = vim.fn.line('.') -- get current line
  local app_name = get_app_name(current_file)
  local test_file = current_file:match(app_name .. "/(test/.*)")
  local command = MixCommand .. " --app " .. app_name .. " " .. MixTest .. " " .. test_file .. ":" .. current_line .. " " .. ExtraOptions
  return command
end

local execute_test_command = function (command)
  if not command then
    return
  end

  print("Running command: " .. command)
  -- Open the floating window
  local buf, win = open_floating_window()

  vim.fn.termopen(command, {
    on_stdout = function(_, data, _)
      if data then
        -- Keep focus on the last line of the buffer when new output is received
        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
      end
    end,
    on_stderr = function(_, data, _)
      if data then
        -- Ensure the cursor moves to the last line for error output as well
        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
      end
    end,
    on_exit = function(_, _, _)
      vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "Press 'q' to close this window." })
      vim.api.nvim_buf_set_keymap(buf, 'n', 'q', '<cmd>bd!<CR>', { noremap = true, silent = true })
    end
  })
end

local run_all_tests = function()
  local command = all_tests_command()
  execute_test_command(command)
end
local run_app_tests = function()
  local command = app_tests_command()
  execute_test_command(command)
end
local run_file_tests = function()
  local command = file_tests_command()
  execute_test_command(command)
end
local run_current_test = function()
  local command = current_test_command()
  execute_test_command(command)
end

vim.api.nvim_create_user_command('RunUmbrellaAllTests', run_all_tests, {})
vim.api.nvim_create_user_command('RunUmbrellaAppTests', run_app_tests, {})
vim.api.nvim_create_user_command('RunUmbrellaFileTests', run_file_tests, {})
vim.api.nvim_create_user_command('RunUmbrellaTest', run_current_test, {})

-- Key mappings
vim.api.nvim_set_keymap('n', '<leader>ta', ':RunUmbrellaAllTests<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>ts', ':RunUmbrellaAppTests<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>tf', ':RunUmbrellaFileTests<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>t', ':RunUmbrellaTest<CR>', { noremap = true, silent = true })
