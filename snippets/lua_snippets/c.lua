local ls = require("luasnip")
require("luasnip.session.snippet_collection").clear_snippets(vim.bo.filetype)
local s, i, t, c = ls.snippet, ls.insert_node, ls.text_node, ls.choice_node
local fmt = require("luasnip.extras.fmt").fmta

ls.add_snippets("c", {
   -- Snippet for the main function
   s("main", fmt([[
      int main(<cond>) {
         <body>
         return 0;
      }
   ]], {
      cond = c(1, {
         t("void"),                  -- Option for void
         t("int argc, char *argv[]") -- Option for argc, argv
      }),
      body = i(2)                    -- Placeholder for the body of the function
   })),

   -- Single 'if' snippet with options for 'else' and 'else if'
   s("if", fmt([[
      if (<cond>) {
         <body>
      }<else_part>
   ]], {
      cond = i(2, "1"), -- Placeholder for the condition
      body = i(3),      -- Placeholder for the 'if' body
      else_part = c(1, {
         t(""),         -- No additional block
         fmt([[
          else {
            <body>
         }
         ]], { body = i(1) }), -- 'else' block
         fmt([[
          else if (<cond>) {
            <body>
         }
         ]], { cond = i(1, "1"), body = i(2) }) -- 'else if' block
      })
   })),

   -- Single '#if' snippet with options for 'else' and 'else if'
   s("#if", fmt([[
      <cond>
      <body>
      <else_part>
      #endif
   ]], {

      cond = c(2, {
         fmt("#ifdef <cond>", { cond = i(1, "FEATURE_A") }),                     -- Option 1: #ifdef FEATURE_A
         fmt("#ifndef <cond>", { cond = i(1, "FEATURE_A") }),                    -- Option 1: #ifdef FEATURE_A
         fmt("#if defined(<cond>)", { cond = i(1, "FEATURE_A") }),               -- Option 2: #if defined(FEATURE_A)
         fmt("#if (<cond>)", { cond = i(1, "FEATURE_A > 2") }),                  -- Option 3: #if (FEATURE_A > 2)
         fmt("#if (<cond>)", { cond = i(1, "FEATURE_A > 2 || FEATURE_B > 3") }), -- Option 4: #if (FEATURE_A > 2 || FEATURE_B > 3)
      }),
      body = i(3, "// code"),                                                    -- Placeholder for the conditional block
      else_part = c(1, {
         t(""),                                                                  -- No #else or #elif block
         fmt([[
         #else
         <body>
         ]], { body = i(1, "// code") }), -- Option for #else block
         fmt([[
         #elif (<cond>)
         <body>
         ]], { cond = i(1, "FEATURE_X"), body = i(2, "// code") }), -- Option for #elif block
      }),
   })),
})
