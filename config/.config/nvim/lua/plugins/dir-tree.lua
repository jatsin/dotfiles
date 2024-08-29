return {
    'nvim-tree/nvim-tree.lua',

    config = function ()
      local configs = require('nvim-tree')

      configs.setup({
        renderer = {
          icons = {
            glyphs = {
              folder = {
                arrow_closed = "►",
                arrow_open = "▼",
              },
            },
          },
        },
      })
    end
  }
