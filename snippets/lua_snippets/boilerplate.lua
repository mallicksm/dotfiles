local ls = require("luasnip")
require("luasnip.session.snippet_collection").clear_snippets(vim.bo.filetype)
local s, i, t, c, f = ls.snippet, ls.insert_node, ls.text_node, ls.choice_node, ls.function_node
local d, sn = ls.dynamic_node, ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmta
local utils = require("user_plugins/snippet_utils")

-- Boilerplate for a snippet file
ls.add_snippets("__filetype__", {
   -- Example function snippet
   s("func", fmt([[
      <ret> <fname>(<arg>) {
         <body>
      }
   ]], {
      ret = c(1, { t("void"), t("int"), t("float") }), -- Choice node for return type
      fname = i(2, "function_name"),                   -- Insert node for function name
      arg = i(3, "args"),                              -- Insert node for arguments
      body = i(0, "// TODO: Add your code here")       -- Final insert node for the function body
   })),
})
