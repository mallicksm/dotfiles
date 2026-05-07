-- markview.nvim -- alternative markdown previewer (the other one is
-- render-markdown.nvim). Both are loaded; switch at runtime via :MdViewer.
-- Disabled by default so render-markdown owns rendering on startup.
require('markview').setup({
   preview = {
      enable        = false,
      filetypes     = { 'markdown', 'md', 'quarto', 'rmd', 'typst' },
      icon_provider = 'internal',
   },
})

-- vim: ts=3 sts=3 sw=3 et
