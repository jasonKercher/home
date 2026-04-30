-- =============================================
-- GENERAL OPTIONS
-- =============================================

local opt = vim.opt

opt.number         = true
opt.relativenumber = true
opt.hlsearch       = true
opt.incsearch      = true
opt.ignorecase     = true
opt.wrap           = false
opt.cursorline     = true
opt.signcolumn     = "number"
opt.syntax         = "on"
opt.scrolloff      = 8
opt.colorcolumn    = "81"
opt.encoding       = "utf-8"
opt.backspace      = { "indent", "eol", "start" }

-- Disable mouse control
opt.mouse          = ""

-- Backup / Undo
opt.backup    = true
opt.backupdir = { vim.fn.expand("~/.config/nvim/.backupdir") }
opt.undodir   = { vim.fn.expand("~/.config/nvim/.undodir") }
opt.undofile  = true

-- Listchars / whitespace display
opt.listchars = { tab = "| ", extends = "›", precedes = "‹", nbsp = "·", trail = "·" }
opt.showbreak = "↪ "
opt.list      = true

-- =============================================
-- INDENTATION (Rlc standards)
-- =============================================

opt.softtabstop = 4
opt.tabstop     = 4
opt.shiftwidth  = 4
opt.expandtab   = true

-- =============================================
-- LEADER (must be set before lazy loads plugins)
-- =============================================

vim.g.mapleader = ","

-- =============================================
-- AUTOCOMMANDS
-- =============================================

local augroup = vim.api.nvim_create_augroup("UserConfig", { clear = true })

-- Filetype-specific indentation overrides
vim.api.nvim_create_autocmd("FileType", {
    group    = augroup,
    pattern  = "gitcommit",
    callback = function()
        vim.opt_local.colorcolumn = "73"
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group    = augroup,
    pattern  = { "asm" },
    callback = function()
        vim.opt_local.tabstop     = 8
        vim.opt_local.softtabstop = 8
        vim.opt_local.shiftwidth  = 8
        vim.opt_local.expandtab   = false
        vim.opt_local.list        = false
    end,
})

vim.api.nvim_create_autocmd("FileType", {
    group    = augroup,
    pattern  = { "sh", "odin" },
    callback = function()
        vim.opt_local.tabstop     = 8
        vim.opt_local.softtabstop = 8
        vim.opt_local.shiftwidth  = 8
        vim.opt_local.expandtab   = false
    end,
})

-- LSP keymaps
vim.api.nvim_create_autocmd("LspAttach", {
    group    = vim.api.nvim_create_augroup("UserLspKeymaps", { clear = true }),
    -- Inside your LspAttach callback:
    callback = function(ev)
        local o    = { buffer = ev.buf }
        local ext  = function(desc) return vim.tbl_extend("force", o, { desc = desc }) end
        local lmap = vim.keymap.set

        lmap("n", "<leader>f", function() 
            vim.lsp.buf.format({ async = true }) 
        end, ext("Format buffer"))

        lmap("v", "<C-k>", function()
            vim.lsp.buf.format({ range = {} })
            -- Exit visual mode
            vim.api.nvim_feedkeys(
                vim.api.nvim_replace_termcodes("<Esc>", true, false, true), 
                "n", 
                false
            )
        end, ext("Format selection and exit Visual mode"))

        lmap("n", "gd",         vim.lsp.buf.definition,     ext("Go to definition"))
        lmap("n", "gD",         vim.lsp.buf.declaration,    ext("Go to declaration"))
        lmap("n", "gr",         vim.lsp.buf.references,     ext("References"))
        lmap("n", "gi",         vim.lsp.buf.implementation, ext("Go to implementation"))
        lmap("n", "K",          vim.lsp.buf.hover,          ext("Hover docs"))
        lmap("n", "<leader>rn", vim.lsp.buf.rename,         ext("Rename symbol"))
        lmap("n", "<leader>ca", vim.lsp.buf.code_action,    ext("Code action"))
        lmap("n", "[d",         vim.diagnostic.goto_prev,   ext("Prev diagnostic"))
        lmap("n", "]d",         vim.diagnostic.goto_next,   ext("Next diagnostic"))
        lmap("n", "<leader>e",  vim.diagnostic.open_float,  ext("Show diagnostic"))
    end,
})

-- =============================================
-- LAZY.NVIM BOOTSTRAP
-- =============================================

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
        "git", "clone", "--filter=blob:none",
        "https://github.com/folke/lazy.nvim.git",
        "--branch=stable",
        lazypath,
    })
end
vim.opt.rtp:prepend(lazypath)

-- =============================================
-- PLUGINS & NATIVE LSP CONFIG
-- =============================================

require("lazy").setup({
    -- (Colors, UI, and Utility plugins remain same as your source)
    {
        "morhetz/gruvbox",
        lazy = false,
        priority = 1000,
        config = function()
            vim.opt.termguicolors = true
            vim.opt.background = "dark"
            vim.cmd("colorscheme gruvbox")
        end,
    },
    { "romainl/flattened", lazy = true },
    {
        "vim-airline/vim-airline",
        dependencies = { "vim-airline/vim-airline-themes" },
        config = function() vim.g.airline_theme = "gruvbox" end,
    },
    {
        "Yggdroot/indentLine",
        config = function() vim.g.indentLine_char = "┊" end,
    },
    { "mbbill/undotree", cmd = "UndotreeToggle" },
    { "jasonKercher/vim-abolish" },
    {
        'nvim-telescope/telescope.nvim', version = '*',
        dependencies = { 'nvim-lua/plenary.nvim', { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' } }
    },

    -- NATIVE COMPLETION
    {
        "hrsh7th/nvim-cmp",
        event = "InsertEnter",
        dependencies = { "hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "L3MON4D3/LuaSnip", "saadparwaiz1/cmp_luasnip" },
        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")
            cmp.setup({
                snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
                mapping = cmp.mapping.preset.insert({
                    ["<CR>"] = cmp.mapping.confirm({ select = true }),
                    ["<Tab>"] = cmp.mapping(function(fallback)
                        if cmp.visible() then cmp.select_next_item() elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump() else fallback() end
                    end, { "i", "s" }),
                }),
                sources = cmp.config.sources({ { name = "nvim_lsp" } }, { { name = "buffer" } }),
            })
        end,
    },
})

-- =============================================
-- NATIVE LSP SETUP
-- =============================================
local capabilities = require("cmp_nvim_lsp").default_capabilities()

-- Define clangd
vim.lsp.config['clangd'] = {
    cmd = { 'clangd' }, -- Make sure this is in your $PATH
    filetypes = { 'c', 'cpp', 'objc', 'objcpp' },
    root_markers = { '.git', 'compile_commands.json', 'compile_flags.txt' },
    capabilities = capabilities,
}

-- Define bashls
vim.lsp.config['bashls'] = {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'sh' },
    root_markers = { '.git' },
    capabilities = capabilities,
}

vim.lsp.config['bashls'] = {
    cmd = { 'bash-language-server', 'start' },
    filetypes = { 'sh' },
    root_markers = { '.git' },
    capabilities = capabilities,
}

vim.lsp.config['ols'] = {
    cmd = { 'ols', 'start' },
    filetypes = { 'odin' },
    root_markers = { '.git' },
    capabilities = capabilities,
}

-- Enable them
vim.lsp.enable({ 'clangd', 'bashls', 'ols' })


-- =============================================
-- KEYMAPS
-- =============================================

local map = vim.keymap.set

-- Strip trailing whitespace
map("n", "<F12>", ":%s/[\\t ]\\+$//<CR>", { desc = "Strip trailing whitespace" })

-- Disable F1 help
map("n", "<F1>", "<nop>")

-- Undotree toggle
map("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "Toggle Undotree" })

map('n', ']g', vim.diagnostic.goto_next, { desc = "Next error" })
map('n', '[g', vim.diagnostic.goto_prev, { desc = "Prev error" })

local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
map('n', '<leader>fg', builtin.live_grep,  { desc = 'Live Grep' })
map('n', '<leader>fb', builtin.buffers,    { desc = 'List Buffers' })
map('n', '<leader>fh', builtin.help_tags,  { desc = 'Help Tags' })

