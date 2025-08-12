return {
  "pmizio/typescript-tools.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "neovim/nvim-lspconfig" },
  opts = {
    on_attach = function(client, bufnr)
      -- Disable formatting from typescript-tools to avoid conflicts
      client.server_capabilities.documentFormattingProvider = false
    end,
    settings = {
      -- Optional: Configure TypeScript settings if needed
      typescript = {
        format = {
          enable = false, -- Explicitly disable formatting
        },
      },
    },
  },
}
