local ls = require("luasnip")
require("luasnip.session.snippet_collection").clear_snippets(vim.bo.filetype)
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("all", {
   s("block", {
      t({ "//" .. string.rep("=", 78), "" }), -- First line of 80 '=' characters
      i(1, { "// comment", "" }),             -- Editable placeholder
      t({ "//" .. string.rep("=", 78), "" }), -- final line of 80 '=' characters
   }),
})
