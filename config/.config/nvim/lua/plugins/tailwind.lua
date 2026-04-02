return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        tailwindcss = {
          settings = {
            tailwindCSS = {
              includeLanguages = {
                elixir = "phoenix-heex",
                eelixir = "html-eex",
                heex = "phoenix-heex",
              },
              experimental = {
                classRegex = {
                  -- Match class attributes in ~H sigils
                  '~H"""[\\s\\S]*?class[:|=]\\s*"([^"]*)"[\\s\\S]*?"""',
                  -- Match class attributes in .heex files
                  'class[:|=]\\s*"([^"]*)"',
                  -- Match class in assigns
                  'class:\\s*"([^"]*)"',
                },
              },
            },
          },
        },
      },
      setup = {
        tailwindcss = function(_, opts)
          opts.filetypes = opts.filetypes or {}

          -- Add default filetypes
          vim.list_extend(opts.filetypes, vim.lsp.config.tailwindcss.filetypes)

          -- Remove excluded filetypes
          --- @param ft string
          opts.filetypes = vim.tbl_filter(function(ft)
            return not vim.tbl_contains(opts.filetypes_exclude or {}, ft)
          end, opts.filetypes)

          -- Add additional filetypes
          vim.list_extend(opts.filetypes, opts.filetypes_include or {})
        end,
      },
    },
  },
}
