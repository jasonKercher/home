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

opt.mouse          = ""

opt.backup    = true
opt.backupdir = { vim.fn.expand("~/.config/nvim/.backupdir") }
opt.undodir   = { vim.fn.expand("~/.config/nvim/.undodir") }
opt.undofile  = true

opt.listchars = { tab = "| ", extends = "›", precedes = "‹", nbsp = "·", trail = "·" }
opt.showbreak = "↪ "
opt.list      = true

-- All or nothing here.
--opt.inccommand     = ""
--opt.foldmethod     = "syntax"
--opt.foldlevelstart = 20

vim.g.mapleader = ","


local tabs_rlc = false
local function set_tabs_rlc()
  vim.opt.softtabstop = 4
  vim.opt.tabstop     = 4
  vim.opt.shiftwidth  = 4
  vim.opt.expandtab   = true
  vim.notify("Tabs: RLC")

  tabs_rlc = true
end
local function set_tabs_default()
  vim.opt.softtabstop = 8
  vim.opt.tabstop     = 8
  vim.opt.shiftwidth  = 8
  vim.opt.expandtab   = false
  vim.notify("Tabs: default")

  tabs_rlc = false
end
--set_tabs_rlc()

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
        vim.opt_local.list = false
    end,
})

-- No auto comment from previous line.
--vim.api.nvim_create_autocmd("FileType", {
--  pattern = "*",
--  callback = function()
--    vim.opt_local.formatoptions:remove({ "r", "o" })
--  end,
--})

-- Return to last edit position when opening files
vim.api.nvim_create_autocmd("BufReadPost", {
    group    = augroup,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
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

        -- quick fix
        lmap('n', '<leader>qf', vim.lsp.buf.code_action, { desc = "Quick Fix" })

        lmap("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
        end, ext("Format buffer"))

        lmap("n", "<C-k>", function()
            local line = vim.api.nvim_win_get_cursor(0)[1]
            vim.lsp.buf.format({
                range = {
                    ["start"] = { line, 0 },
                    ["end"] = { line, 999 },
                }
            })
        end, ext("Format current line"))

        lmap("v", "<C-k>", function()
            local start_line = math.min(vim.fn.line("v"), vim.fn.line("."))
            local end_line   = math.max(vim.fn.line("v"), vim.fn.line("."))
            local total      = vim.api.nvim_buf_line_count(0)

            if start_line > 1 then
                start_line = start_line - 1
            end

            vim.cmd("normal! " .. start_line .. "GV" .. end_line .. "G")
            vim.lsp.buf.format()

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
        "whatyouhide/vim-gotham",
        lazy = false,
        priority = 1000,
        config = function()
            vim.opt.termguicolors = true
            vim.opt.background = "dark"
            vim.cmd("colorscheme gotham")
        end,
    },
    --{
    --    "morhetz/gruvbox",
    --    lazy = false,
    --    priority = 1000,
    --    config = function()
    --        vim.opt.termguicolors = true
    --        vim.opt.background = "light"
    --        vim.cmd("colorscheme gruvbox")
    --    end,
    --},
    { "romainl/flattened", lazy = true },
    {
        "vim-airline/vim-airline",
        dependencies = { "vim-airline/vim-airline-themes" },
        config = function() vim.g.airline_theme = "gotham" end,
        --config = function() vim.g.airline_theme = "gruvbox" end,
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
                sources = cmp.config.sources({ { name = "nvim_lsp" } }, { { name = "buffer" } }, { { name = "path" } }),
            })
        end,
    },
})

-- Post plugin import
vim.api.nvim_set_hl(0, 'Comment', { fg = "#504870", italic=true })


-- Lsp
------
local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config['clangd'] = {
    cmd = { 'clangd' }, -- Make sure this is in your $PATH
    filetypes = { 'h', 'c', 'cpp', 'objc', 'objcpp' },
    root_markers = { '.clang-format', '.git', 'compile_commands.json', 'compile_flags.txt' },
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

vim.lsp.enable({ 'clangd', 'bashls', 'ols' })


-- Remaps

local map = vim.keymap.set

map("n", "<F12>", ":%s/[\\t ]\\+$//<CR>", { desc = "Strip trailing whitespace" })

-- Disable F1 help
map("n", "<F1>", "<nop>")

map("n", "<leader>u", ":UndotreeToggle<CR>", { desc = "Toggle Undotree" })

map('n', ']g', vim.diagnostic.goto_next, { desc = "Next error" })
map('n', '[g', vim.diagnostic.goto_prev, { desc = "Prev error" })

local builtin = require('telescope.builtin')
map('n', '<leader>ff', builtin.find_files, { desc = 'Find Files' })
map('n', '<leader>fg', builtin.live_grep,  { desc = 'Live Grep' })
map('n', '<leader>fb', builtin.buffers,    { desc = 'List Buffers' })
map('n', '<leader>fh', builtin.help_tags,  { desc = 'Help Tags' })

-- RLC style toggle
map("n", "<leader>r", function()
  if tabs_rlc then
    set_tabs_default()
  else
    set_tabs_rlc()
  end
end, { desc = "Toggle tab style (custom <-> default)" })

-- Toggle LSP diagnostics globally
map("n", "<leader>d", function()
    local is_enabled = vim.diagnostic.is_enabled()
    vim.diagnostic.enable(not is_enabled)
    vim.notify("Diagnostics: " .. (is_enabled and "OFF" or "ON"))
end, { desc = "Toggle LSP Diagnostics" })


