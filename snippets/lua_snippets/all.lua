local ls = require("luasnip")
require("luasnip.session.snippet_collection").clear_snippets(vim.bo.filetype)
local s, i, t, c = ls.snippet, ls.insert_node, ls.text_node, ls.choice_node
local fmt = require("luasnip.extras.fmt").fmta

ls.add_snippets("all", {
   s("block", {
      t({ "//" .. string.rep("=", 78), "" }), -- First line of 80 '=' characters
      i(1, { "// comment", "" }),             -- Editable placeholder
      t({ "//" .. string.rep("=", 78), "" }), -- final line of 80 '=' characters
   }),
})
