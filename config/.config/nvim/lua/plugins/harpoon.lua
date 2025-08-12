-- lua/plugins/harpoon.lua
-- Harpoon plugin configuration for Lazy.nvim (Using Harpoon 1 for stability)

return {
  "ThePrimeagen/harpoon",
  -- Using the main branch (Harpoon 1) instead of harpoon2 for better compatibility
  dependencies = { "nvim-lua/plenary.nvim" },
  config = function()
    local harpoon = require("harpoon")
    local mark = require("harpoon.mark")
    local ui = require("harpoon.ui")

    -- Setup harpoon
    harpoon.setup({
      global_settings = {
        save_on_toggle = false,
        save_on_change = true,
        enter_on_sendcmd = false,
        tmux_autoclose_windows = false,
        excluded_filetypes = { "harpoon" },
        mark_branch = false,
      },
    })

    -- Key mappings
    local keymap = vim.keymap.set
    local opts = { noremap = true, silent = true }

    -- Core harpoon functionality
    keymap("n", "<leader>a", mark.add_file, opts)
    keymap("n", "<C-e>", ui.toggle_quick_menu, opts)

    -- number-based navigation
    keymap("n", "<leader>1", function()
      ui.nav_file(1)
    end, opts)
    keymap("n", "<leader>2", function()
      ui.nav_file(2)
    end, opts)
    keymap("n", "<leader>3", function()
      ui.nav_file(3)
    end, opts)
    keymap("n", "<leader>4", function()
      ui.nav_file(4)
    end, opts)
    keymap("n", "<leader>5", function()
      ui.nav_file(5)
    end, opts)

    -- Remove current file from harpoon list
    keymap("n", "<leader>hr", mark.rm_file, opts)

    -- Clear all harpoon marks
    keymap("n", "<leader>hc", mark.clear_all, opts)

    -- Additional utility mappings
    keymap("n", "<leader>hn", ui.nav_next, opts)
    keymap("n", "<leader>hp", ui.nav_prev, opts)
  end,
}
