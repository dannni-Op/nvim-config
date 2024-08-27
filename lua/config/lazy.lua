local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- Example using a list of specs with the default options
vim.g.mapleader = "" -- Make sure to set `mapleader` before lazy so your mappings are correct
vim.g.maplocalleader = "" -- Same for `maplocalleader`

require("lazy").setup({
  "folke/which-key.nvim",
  { "folke/neoconf.nvim", cmd = "Neoconf" },
  "folke/neodev.nvim",
  {
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      style = "moon"
    },
  },
  {
    'nvim-telescope/telescope.nvim', tag = '0.1.6',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
      vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})
    end,
  },
  {
    'numToStr/Comment.nvim',
    opts = {
      -- add any options here
    },
    lazy = false,
  },
  { "lukas-reineke/indent-blankline.nvim", main = "ibl", opts = {} },
  {
    "hrsh7th/nvim-cmp",
    version = false, -- last release is way too old
    event = "InsertEnter",
    dependencies = {
      'hrsh7th/cmp-buffer',
      'hrsh7th/cmp-path',
      'hrsh7th/nvim-cmp',
      'hrsh7th/cmp-nvim-lsp',
    },
    opts = function()
      local cmp = require('cmp')
      local defaults = require("cmp.config.default")()
      return {
        -- ... (other options)

        completion = {
          completeopt = "menu,menuone,noinsert",
        },
        mapping = cmp.mapping.preset.insert({
          -- ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
          -- ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
          ['<C-b>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.abort(),
          ['<CR>'] = cmp.mapping.confirm({ 
            -- behavior = cmp.ConfirmBehavior.Replace,
            select = true 
          }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
        }),
        sources = cmp.config.sources({
          { name = 'path' },
          { name = 'nvim_lsp' },
        }, {
            { name = 'buffer' },
          })
      }
    end
  },
  {
    'nvim-lualine/lualine.nvim',
    opts = function()
      return {
        options = {
          icons_enabled = false,
          theme = 'horizon',
          component_separators = "",
          section_separators = "",
          globalstatus = true,
          refresh = {
            statusline = 1000,
            tabline = 1000,
            winbar = 1000,
          }
        },
        sections = {
          lualine_a = {'mode'},
          lualine_b = {'branch', 'diff', 'diagnostics'},
          lualine_c = {'filename'},
          lualine_x = {'encoding', 'fileformat', 'filetype'},
          lualine_y = {'progress'},
          lualine_z = {'location'}
        },
      }
    end
  },
  {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    config = true
    -- use opts = {} for passing setup options
    -- this is equalent to setup({}) function
  },
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    config = function () 
      local configs = require("nvim-treesitter.configs")

      configs.setup({
        -- ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "elixir", "heex", "javascript", "html", "php" },
        ensure_installed = { "c", "lua", "vim", "vimdoc", "query", "javascript", "html", 'css', 'json', "php" },
        sync_install = false,
        highlight = { enable = true },
        indent = { enable = true },  
      })
    end
  },
  {
    'williamboman/mason.nvim',
    config = function()
      local mason = require('mason').setup()
    end
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require('lspconfig')

      -- LSP servers
      local servers = {
        -- PHP
        intelephense = {
          cmd = { 'intelephense', '--stdio' },
          filetypes = { 'php' },
          root_dir = function(fname)
            return vim.fn.getcwd()
          end,
        },
        pyright = {
          filetypes = { 'python' },
          root_dir = function(fname)
            return vim.fn.getcwd()
          end,
        },
        -- JavaScript
        tsserver = {
          cmd = { 'typescript-language-server', '--stdio'},
          filetypes = { 'javascript', 'typescript' },
          root_dir = function(fname)
            return vim.fn.getcwd()
          end,
        },
        -- Lua
        lua_ls = {
          filetypes = { 'lua' },
          root_dir = function(fname)
            return vim.fn.getcwd()
          end,
        },
        -- Other language servers...
      }

      -- Setup LSP servers
      for server, config in pairs(servers) do
        lspconfig[server].setup(config)
      end

      -- LSP settings
      vim.lsp.handlers['textDocument/publishDiagnostics'] = vim.lsp.with(
        vim.lsp.diagnostic.on_publish_diagnostics,
        {
          -- Enable diagnostics for all buffers
          enable = true,
        }
      )
    end
  }
})
