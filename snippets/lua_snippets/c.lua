local ls = require("luasnip")
require("luasnip.session.snippet_collection").clear_snippets(vim.bo.filetype)
local s, i, t, c, f = ls.snippet, ls.insert_node, ls.text_node, ls.choice_node, ls.function_node
local d, sn = ls.dynamic_node, ls.snippet_node
local fmt = require("luasnip.extras.fmt").fmta
local utils = require("user_plugins/snippet_utils")

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

   -- 'for' snippet with options for standard form and free form
   s("for", fmt(
      [[
      for (<loop_header>) {
         <body>
      }
      <final>
      ]], {
         loop_header = c(1, {
            fmt("int <var> = 0; <var> << <limit>; <var>++", {
               var = i(1, "i"),
               limit = i(2, "n")
            }, { repeat_duplicates = true }),
            fmt("<init>;<cond>;<iter>", {
               init = i(1),
               cond = i(2),
               iter = i(3)
            }),
         }),
         body = i(2),
         final = i(nil, { "" })
      }
   )),

   -- 'do' snippet
   s("do", fmt(
      [[
   do {
      <body>
   } while (<cond>);
   <final>
   ]], {
         cond = i(1),
         body = i(2),
         final = i(nil, { "" })
      }
   )),

   -- 'while' snippet
   s("while", fmt(
      [[
   while (<cond>) {
      <body>
   }
   <final>
   ]], {
         cond = i(1),
         body = i(2),
         final = i(nil, { "" })
      }
   )),

   -- '#include' snippet with options "" or <>
   s("inc", fmt("#include <open><header><close>", {
      open = c(1, { t("<"), t('"'), }),
      header = i(2, "stdio.h"),
      close = d(3, function(args)
         if args[1][1] == "<" then
            return sn(nil, t(">"))
         else
            return sn(nil, t('"'))
         end
      end, { 1 }),
   })),

   -- switch statement
   s("switch", fmt([[
   switch (<cond>) {
      case <const>:
         <case_part>;
         break;
      default:
         <default_part>;
         break;
   }
   <final>
   ]], {
      cond = i(1, "expression"),           -- Placeholder for the switch expression
      const = i(2, "constant"),            -- Placeholder for the case constant
      case_part = i(3, "case_part"),       -- Placeholder for the case printf message
      default_part = i(4, "default_part"), -- Placeholder for the default printf message
      final = i(nil, { "" })
   })),

   -- Prototype snippet for a highlighted function definition
   s("proto", fmt("<>;", {
      f(function(_, snip)
         return snip.env.TM_SELECTED_TEXT or ""
      end)
   }))

})
