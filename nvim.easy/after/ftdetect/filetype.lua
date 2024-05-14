-- Module for defining new filetypes. I picked up these configurations based on inspirations from this dotfiles repo:
-- https://github.com/davidosomething/dotfiles/blob/be22db1fc97d49516f52cef5c2306528e0bf6028/nvim/lua/dko/filetypes.lua

vim.filetype.add({
   -- Detect and assign filetype based on the extension of the filename
   extension = {
      v = "verilog_systemverilog",
      vh = "verilog_systemverilog",
      vp = "verilog_systemverilog",
      sv = "verilog_systemverilog",
      svh = "verilog_systemverilog",
      svp = "verilog_systemverilog",
      qel = "tcl",
      fs = "tcl",
      tdf = "tdf",
      f = "f",
   },
   -- Detect and apply filetypes based on the entire filename
   filename = {
      ["bash_profile"] = "sh",
      ["cshrc"] = "csh",
      ["shellrc"] = "csh",
      [".shellrc"] = "csh",
   },
})
