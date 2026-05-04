-- Pretty markdown previewer (alternative to render-markdown.nvim).
-- Both plugins are installed; switch between them with `:MdViewer`.
return {
   'OXY2DEV/markview.nvim',
   -- per upstream README: do NOT lazy-load, the plugin self-lazy-loads
   lazy = false,
   -- Lazy.nvim loads higher priority first. Colorscheme is 1000, so anything
   -- below that loads after it; 100 is the conventional "low priority eager load"
   -- value (lower than mini/snacks defaults). Markview's hl groups inherit from
   -- the colorscheme so this ordering matters.
   priority = 100,
   opts = {
      preview = {
         -- Start disabled so render-markdown owns rendering by default.
         -- Toggle with `:MdViewer markview` (or `:Markview Enable`).
         enable = false,
         filetypes = { 'markdown', 'md', 'quarto', 'rmd', 'typst' },
         icon_provider = 'internal', -- no extra deps required
      },
   },
   config = function(_, opts)
      require('markview').setup(opts)
   end,
}
-- vim: ts=3 sts=3 sw=3 et
