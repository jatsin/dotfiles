return {
  {
    'vim-test/vim-test',
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "nvim-neotest/neotest-plenary",
      "nvim-neotest/neotest-vim-test",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter",
      -- "Issafalcon/neotest-dotnet" -- https://github.com/Issafalcon/neotest-dotnet/issues/114
      "DarkKronicle/neotest-dotnet" -- until the above is fixed
    },
    config = function ()
      require("neotest").setup({
        adapters = {
          require("neotest-dotnet")({
            dap = {
              args = {justMyCode = false },
              adapter_name = "coreclr"
            },
            custom_attributes = {
              -- mstest = {
                -- "TestMethod",
                -- test = "TestMethod",
                -- fixture = "TestClass",
                -- setup = "TestInitialize",
                -- teardown = "TestCleanup"
              -- },
            },
          }),
          require("neotest-plenary"),
          require("neotest-vim-test")({
            ignore_file_types = { "python", "vim", "lua" },
          }),
        },
        -- log_level = 1,
      })
    end
  }
}
