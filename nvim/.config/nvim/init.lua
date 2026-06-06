-- ── Opciones básicas ──────────────────────────────────────
vim.opt.number         = true
vim.opt.relativenumber = false
vim.opt.cursorline     = true
vim.opt.termguicolors  = true
vim.opt.signcolumn     = "yes"
vim.opt.scrolloff      = 8
vim.opt.tabstop        = 2
vim.opt.shiftwidth     = 2
vim.opt.expandtab      = true
vim.opt.clipboard      = "unnamedplus"
vim.opt.ignorecase     = true
vim.opt.smartcase      = true
vim.opt.splitright     = true
vim.opt.splitbelow     = true
vim.opt.showmode       = false

-- ── Leader ────────────────────────────────────────────────
vim.g.mapleader = " "

-- ── Atajos básicos ────────────────────────────────────────
vim.keymap.set("n", "<leader>w", ":w<CR>")
vim.keymap.set("n", "<leader>q", ":q<CR>")
vim.keymap.set("n", "<Esc>",     ":nohl<CR>")
vim.keymap.set("n", "<C-h>",     "<C-w>h")
vim.keymap.set("n", "<C-l>",     "<C-w>l")
vim.keymap.set("n", "<C-j>",     "<C-w>j")
vim.keymap.set("n", "<C-k>",     "<C-w>k")

-- ── Lazy.nvim (gestor de plugins) ─────────────────────────
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({ "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({

  -- Tema Catppuccin
  { "catppuccin/nvim", name = "catppuccin", priority = 1000,
    config = function()
      require("catppuccin").setup({
        flavour = "mocha",
        transparent_background = true,
      })
      vim.cmd.colorscheme("catppuccin")
    end
  },

  -- Statusline minimalista
  { "nvim-lualine/lualine.nvim",
    config = function()
      require("lualine").setup({
        options = {
          theme = "catppuccin",
          section_separators = "",
          component_separators = "│",
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch" },
          lualine_c = { "filename" },
          lualine_x = { "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end
  },

  -- Dashboard simple
  { "goolord/alpha-nvim",
    config = function()
      local alpha = require("alpha")
      local dashboard = require("alpha.themes.dashboard")
      dashboard.section.header.val = {
        "                                                          ",
        "  ████████╗██████╗  █████╗ ███████╗ █████╗ ██╗      ██████╗  █████╗ ██████╗  ",
        "  ╚══██╔══╝██╔══██╗██╔══██╗██╔════╝██╔══██╗██║     ██╔════╝ ██╔══██╗██╔══██╗ ",
        "     ██║   ██████╔╝███████║█████╗  ███████║██║     ██║  ███╗███████║██████╔╝ ",
        "     ██║   ██╔══██╗██╔══██║██╔══╝  ██╔══██║██║     ██║   ██║██╔══██║██╔══██╗ ",
        "     ██║   ██║  ██║██║  ██║██║     ██║  ██║███████╗╚██████╔╝██║  ██║██║  ██║ ",
        "     ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝     ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝ ",
        "                                                          ",
      }
      dashboard.section.buttons.val = {
        dashboard.button("e", "  Nuevo archivo",  ":ene<CR>"),
        dashboard.button("f", "  Buscar archivo", ":Ex<CR>"),
        dashboard.button("q", "  Salir",          ":qa<CR>"),
      }
      vim.api.nvim_set_hl(0, "AlphaHeader", { fg = "#cba6f7" })
      dashboard.section.header.opts.hl = "AlphaHeader"
      alpha.setup(dashboard.opts)
    end
  },

})
