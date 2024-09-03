return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "rcarriga/nvim-dap-ui",
      "theHamsta/nvim-dap-virtual-text",
      "nvim-neotest/nvim-nio",
      "williamboman/mason.nvim",
    },
    config = function()
      local dap = require("dap")
      local ui = require("dapui")

      require "dapui".setup()
      vim.keymap.set('n', '<leader>do', function() require("dapui").open() end)
      vim.keymap.set('n', '<leader>dc', function() require("dapui").close() end)

      -- C#
      dap.adapters.coreclr = {
        type = "executable",
        command = vim.fn.stdpath("data") .. "/mason/bin/netcoredbg",
        args = { "--interpreter=vscode" }
      }
      dap.configurations.cs = {
        {
          type = "coreclr",
          name = "launch - netcoredbg",
          request = "launch",
          program = function()
            -- src/Web/bin/Debug/net8.0/Web.dll
            -- return vim.fn.input("Path to dll: ", vim.fn.getcwd() .. "/src/Web/bin/Debug/net8.0/", "file")
            return vim.fn.getcwd() .. "/src/Web/bin/Debug/net8.0/Web.dll"
          end,
        },
      }
      -- Elixir
      dap.adapters.mix_task = {
        type = 'executable',
        command = vim.fn.stdpath("data") .. '/mason/bin/elixir-ls-debugger',
        args = {}
      }
      dap.configurations.elixir = {
        {
          type = "mix_task",
          name = "mix test",
          task = 'test',
          taskArgs = { "--trace" },
          request = "launch",
          startApps = true, -- for Phoenix projects
          projectDir = "${workspaceFolder}",
          requireFiles = {
            "test/**/test_helper.exs",
            "test/**/*_test.exs"
          }
        },
      }

      vim.keymap.set("n", "<space>b", dap.toggle_breakpoint)
      vim.keymap.set("n", "<space>gb", dap.run_to_cursor)

      -- Eval under cursor
      vim.keymap.set("n", "<space>?", function ()
        require("dapui").eval(nil, { enter = true})
      end)

      dap.listeners.before.attach.dapui_config = function ()
        ui.open()
      end
      dap.listeners.before.launch.dapui_config = function ()
        ui.open()
      end
      dap.listeners.before.event_terminated.dapui_config = function ()
        ui.close()
      end
      dap.listeners.before.event_exited.dapui_config = function ()
        ui.close()
      end
    end,
  },
}
