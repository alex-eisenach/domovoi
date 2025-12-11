" ==================== LazyVim-style config for Neovim 0.10.x (RPi 5) ====================
call plug#begin('~/.local/share/nvim/plugged')

" ── Core UI & UX (the LazyVim look) ─────────────────────
Plug 'morhetz/gruvbox'                              " colorscheme
Plug 'nvim-lualine/lualine.nvim'                    " statusline
Plug 'kyazdani42/nvim-web-devicons'                 " icons (needs nerd font on host!)
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'akinsho/bufferline.nvim', { 'tag': 'v4.*' }   " fancy tabs
Plug 'lewis6991/gitsigns.nvim'                      " git signs in gutter
Plug 'lukas-reineke/indent-blankline.nvim'          " indent guides
Plug 'folke/which-key.nvim'                         " keybinding popup help

" ── Fuzzy finding & navigation ─────────────────────────
Plug 'nvim-telescope/telescope.nvim', { 'branch': '0.1.x' }
Plug 'nvim-telescope/telescope-fzf-native.nvim', { 'do': 'make' }
Plug 'nvim-lua/plenary.nvim'                        " required by telescope

" ── Treesitter (syntax + more) ─────────────────────────
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" ── LSP, completion, snippets ──────────────────────────
Plug 'neovim/nvim-lspconfig'
Plug 'hrsh7th/nvim-cmp'                             " completion engine
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-path'
Plug 'hrsh7th/cmp-cmdline'
Plug 'L3MON4D3/LuaSnip', {'tag': 'v2.*'}
Plug 'saadparwaiz1/cmp_luasnip'
Plug 'rafamadriz/friendly-snippets'

" ── Quality of life ────────────────────────────────────
Plug 'tpope/vim-fugitive'          " :Git
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'windwp/nvim-autopairs'
Plug 'numToStr/Comment.nvim'

call plug#end()

" ── Basic settings ─────────────────────────────────────
set termguicolors
set background=dark
colorscheme gruvbox
let g:gruvbox_contrast_dark = "hard"
let g:gruvbox_improved_warnings = 1

set number relativenumber
set mouse=a
set hidden
set ignorecase smartcase
set splitright splitbelow
set clipboard=unnamedplus
set completeopt=menu,menuone,noselect
set updatetime=300
set signcolumn=yes
let mapleader = " "

" ── Plugin configurations (Lua-style but in Vimscript) ──
lua << LUA
-- Gruvbox

-- Lualine (LazyVim look)
require('lualine').setup {
  options = { theme = 'gruvbox', section_separators = '', component_separators = '' }
}

-- Bufferline
require('bufferline').setup { options = { diagnostics = "nvim_lsp" }}

-- Gitsigns
require('gitsigns').setup()

-- Indent blankline
require('ibl').setup()

-- Which-key (shows keybindings)
require('which-key').setup()

-- Telescope
require('telescope').setup()
require('telescope').load_extension('fzf')

-- Treesitter (safe parsers only – no heavy ones)
require('nvim-treesitter.configs').setup {
  ensure_installed = { "python", "bash", "lua", "dockerfile", "yaml", "json", "markdown" },
  highlight = { enable = true },
  indent = { enable = true },
}

-- LSP + cmp (auto-setup most servers)
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

local servers = { 'pyright', 'bashls', 'dockerls', 'yamlls', 'lua_ls' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup { capabilities = capabilities }
end

-- nvim-cmp
local cmp = require('cmp')
cmp.setup({
  snippet = { expand = function(args) require('luasnip').lsp_expand(args.body) end },
  mapping = cmp.mapping.preset.insert({
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }),
    ['<Tab>'] = cmp.mapping.select_next_item(),
    ['<S-Tab>'] = cmp.mapping.select_prev_item(),
  }),
  sources = {
    { name = 'nvim_lsp' }, { name = 'luasnip' }, { name = 'buffer' }, { name = 'path' }
  }
})

-- Autopairs
require('nvim-autopairs').setup()

-- Comment.nvim
require('Comment').setup()
LUA

" ── Keybindings you’ll love (LazyVim style) ─────────────
nnoremap <leader>ff <cmd>Telescope find_files<CR>
nnoremap <leader>fg <cmd>Telescope live_grep<CR>
nnoremap <leader>fb <cmd>Telescope buffers<CR>
nnoremap <leader>fh <cmd>Telescope help_tags<CR>
nnoremap <leader>gb <cmd>Git blame<CR>
nnoremap gd <cmd>lua vim.lsp.buf.definition()<CR>
nnoremap K  <cmd>lua vim.lsp.buf.hover()<CR>
nnoremap <leader>ca <cmd>lua vim.lsp.buf.code_action()<CR>
nnoremap <leader>rn <cmd>lua vim.lsp.buf.rename()<CR>

" ── Additional plugins (add these lines near the other Plug lines) ──
Plug 'nvim-tree/nvim-tree.lua'                    " Explorer (Snacks-style)
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-tree/nvim-web-devicons'                " Icons for nvim-tree
Plug 'nvim-tree/nvim-tree.lua'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}

" ── Final Lua config (add to the existing lua << LUA block) ──
lua << LUA
-- Ensure treesitter parsers for Python/JSON/YAML/Docker (runs once)
require('nvim-treesitter.install').update({ with_sync = true })()

-- LSP servers we just installed globally
local lspconfig = require('lspconfig')
local capabilities = require('cmp_nvim_lsp').default_capabilities()

lspconfig.pyright.setup{ capabilities = capabilities }
lspconfig.yamlls.setup{ capabilities = capabilities }
lspconfig.dockerls.setup{ capabilities = capabilities }
lspconfig.bashls.setup{ capabilities = capabilities }   -- bonus bash

-- Nvim-Tree (Explorer) – Snacks-style, bound to <leader>e
require("nvim-tree").setup({
  view = { side = "left", width = 36 },
  renderer = { highlight_git = true, icons = { show = { file = true, folder = true } } },
  filters = { dotfiles = false },
})
vim.keymap.set('n', '<leader>e', ':NvimTreeToggle<CR>', { desc = "Toggle file explorer" })

-- ESC → jk in insert mode (super fast, zero delay)
vim.keymap.set('i', 'jk', '<Esc>', { desc = "Exit insert mode with jk" })
LUA
