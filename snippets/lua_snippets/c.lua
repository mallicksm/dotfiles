local ls = require("luasnip")
require("luasnip.session.snippet_collection").clear_snippets(vim.bo.filetype)
local s = ls.snippet
local t = ls.text_node
local c = ls.choice_node
local i = ls.insert_node
local fmt = require("luasnip.extras.fmt").fmt

ls.add_snippets("c", {
   -- Snippet for the main function
   s("main", fmt([[
      int main({}) {{
         {}
         return 0;
      }}
   ]], {
      c(1, {
         t("void"),                  -- Option for void
         t("int argc, char *argv[]") -- Option for argc, argv
      }),
      i(0)                           -- Placeholder for the body of the function
   }, {
      name = "Main function with 2 argument styles"
   })),

   -- Single 'if' snippet with options for 'else' and 'else if'
   s("if", fmt([[
      if ({}) {{
         {}
      }}{}
   ]], {
      i(2, "1"), -- Placeholder for the condition
      i(3),      -- Placeholder for the 'if' body
      c(1, {
         t(""),  -- No additional block
         fmt([[
          else {{
            {}
         }}
         ]], { i(1) }), -- 'else' block
         fmt([[
          else if ({}) {{
            {}
         }}
         ]], { i(1, "1"), i(2) }) -- 'else if' block
      })
   })),
   s("#if", fmt([[
   #if ({})
   {}
   {}
   #endif
   ]], {
      c(1, {
         t("FEATURE > 2"),                    -- First condition
         t("FEATURE_A > 2 || FEATURE_B > 3"), -- Second condition
         i(nil, "Custom condition"),          -- Custom condition for user input
      }),
      i(2, "// Code for the if block"),       -- Placeholder for the if block
      c(3, {
         t(""),                               -- No elif or else block
         fmt([[
         #else
         {}
         ]], {
            i(1, "// Code for the else block") -- Placeholder for the else block
         }),
         fmt([[
         #elif ({})
         {}
         ]], {
            c(1, {
               t("FEATURE > 2"),                    -- First condition for elif
               t("FEATURE_A > 2 || FEATURE_B > 3"), -- Second condition for elif
               i(nil, "Custom elif condition"),     -- Custom condition for user input
            }),
            i(2, "// Code for the elif block")      -- Placeholder for the elif block
         }),
      }),
   })),
})
