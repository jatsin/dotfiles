return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      -- add additional languages to the default list
      vim.list_extend(opts.ensure_installed, {
        -- "tsx",
        -- "typescript",
        "elixir",
      })
    end,
  },
}
