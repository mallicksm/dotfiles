local M = {}

-- Table mapping filetypes to line comment styles
M.comment_styles = {
  c = "// ",
  cpp = "// ",
  javascript = "// ",
  python = "# ",
  lua = "-- ",
  sh = "# ",
  html = "<!-- ",   -- HTML will use line comment-style start
  tcl = "# ",       -- Fallback for unsupported filetypes
  default = "// ", -- Fallback for unsupported filetypes
}

-- Function to fetch line comment style for the current filetype
M.get_comment_start = function()
  local filetype = vim.bo.filetype -- Get the current buffer's filetype
  return M.comment_styles[filetype] or M.comment_styles.default
end

return M
