return {
  -- Set lualine as statusline
  "nvim-lualine/lualine.nvim",
  enabled = false,
  opts = {
    options = {
      icons_enabled = false,
      theme = "onedark",
      component_separators = "|",
      section_separators = "",
    },
    sections = {
      lualine_a = {
        {
          "buffers",
        },
      },
      lualine_b = {
        {
          "filename",
          path = 1,
        },
      },
    },
  },
}
