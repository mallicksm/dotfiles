local ls = require("luasnip")
require("luasnip.session.snippet_collection").clear_snippets(vim.bo.filetype)
local s, i, t, c, f = ls.snippet, ls.insert_node, ls.text_node, ls.choice_node, ls.function_node
local fmt = require("luasnip.extras.fmt").fmta
local utils = require("user_plugins/snippet_utils")

ls.add_snippets("all", {
   -- snippet for file header
   s("header", fmt([[
      <comment_start>==============================================================================
      <comment_start> Created: <date>
      <comment_start> Author: <user>
      <comment_start>
      <comment_start> Note:
      <comment_start>
      <comment_start> Description: <desc>
      <comment_start>
      <comment_start>==============================================================================
      <final>
   ]], {
      comment_start = f(function() return utils.get_comment_start() end, {}),
      desc = i(1, { "Description" }),
      date = os.date("%b-%d-%Y"),
      user = os.getenv("USER"),
      final = t(nil)
   })),

   -- snippet for single block comment
   s("gbc", fmt([[
      <comment_start>==============================================================================
      <comment_start> <desc>
      <comment_start>==============================================================================
      <final>
   ]], {
      comment_start = f(function() return utils.get_comment_start() end, {}),
      desc = i(1, { "Description" }),
      final = t(nil)
   })),

   -- snippet for single line comment
   s("gcc", fmt([[
      <comment_start> <desc>
      <final>
   ]], {
      comment_start = f(function() return utils.get_comment_start() end, {}),
      desc = i(1, { "Description" }),
      final = t(nil)
   })),

   -- snippet for date time
   s("date", {
      c(1, {
         f(function() return os.date("%Y-%m-%dT%H:%M:%S") end), -- ISO date-time
         f(function() return os.date("%Y-%m-%d") end),          -- Y-m-d
         f(function() return os.date("%d/%m/%Y") end),          -- D/M/Y
         f(function() return os.date("%m/%d/%Y") end),          -- M/D/Y
         f(function() return os.date("%H:%M") end),             -- H:M
         f(function() return os.date("%H:%M:%S") end),          -- H:M:S
         f(function() return os.date("%Y-%m-%d %H:%M") end),    -- Y-m-d H:M
      }),
   }),

})
