-- Pretty markdown previewer (alternative to render-markdown.nvim).
-- Both plugins are installed; switch between them with `:MdViewer`.
return {
   'OXY2DEV/markview.nvim',
   -- per upstream README: do NOT lazy-load, the plugin self-lazy-loads
   lazy = false,
   priority = 49, -- after colorscheme so highlight groups resolve correctly
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
