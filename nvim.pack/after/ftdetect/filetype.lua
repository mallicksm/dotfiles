-- Module for defining new filetypes. I picked up these configurations based on inspirations from this dotfiles repo:
-- https://github.com/davidosomething/dotfiles/blob/be22db1fc97d49516f52cef5c2306528e0bf6028/nvim/lua/dko/filetypes.lua

vim.filetype.add({
   -- Detect and assign filetype based on the extension of the filename
   extension = {
      v = "sv",
      vh = "sv",
      vp = "sv",
      sv = "sv",
      svh = "sv",
      svp = "sv",
      qel = "tcl",
      fs = "tcl",
      tdf = "tdf",
      f = "f",
      scat = "scat",
      h = "c",
      csr = "semifore",
      cmm = "trace32",
      map = "map",
      mdc = "markdown",
      jira = "jira",
   },
   -- Detect and apply filetypes based on the entire filename
   filename = {
      ["bash_profile"] = "sh",
      ["bashrc"] = "sh",
      ["cshrc"] = "csh",
      ["shellrc"] = "csh",
      [".shellrc"] = "csh",
   },
})
