local ls = require("luasnip")
require("luasnip.session.snippet_collection").clear_snippets(vim.bo.filetype)
local s = ls.snippet
local t = ls.text_node
local i = ls.insert_node
local c = ls.choice_node
local fmt = require("luasnip.extras.fmt").fmt

-- Boilerplate for a snippet file
ls.add_snippets("__filetype__", {
   -- Example function snippet
   s("func", fmt([[
      {} {}({}) {{
         {}
      }}
   ]], {
      c(1, { t("void"), t("int"), t("float") }), -- Choice node for return type
      i(2, "function_name"),                     -- Insert node for function name
      i(3, "args"),                              -- Insert node for arguments
      i(0, "// TODO: Add your code here")        -- Final insert node for the function body
   })),
})
