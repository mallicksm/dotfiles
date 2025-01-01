return {
   'simrat39/symbols-outline.nvim',
   config = function()
      require("symbols-outline").setup({
         auto_close = true,             -- Close the outline automatically when opening a file
         autofold_depth = 1,            -- Automatically fold symbols to this depth
         show_numbers = false,          -- Disable line numbers
         show_relative_numbers = false, -- Disable relative line numbers
         show_symbol_details = true,    -- Show additional details for each symbol
         highlight_hovered_item = true, -- Highlight the symbol under the cursor
         keymaps = {                    -- Custom keybindings for the outline
            close = "<Esc>",            -- Close the outline
            goto_location = "<CR>",     -- Go to the symbol location
            focus_location = "o",       -- Focus the symbol without closing the outline
            toggle_preview = "K",       -- Toggle preview of the symbol
            rename_symbol = "r",        -- Rename a symbol
            code_actions = "a",         -- Show code actions for a symbol
         },
         position = "right",            -- Position the outline on the right
         width = 20,                    -- Set the outline window width
      })
   end,
}
