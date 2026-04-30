source ~/.vimrc

" neovim undodir is incompatible with vim!
set undodir=~/.config/nvim/.undodir

" incsearch is laggy when doing search and replace with LSP doing stuff.
"set noincsearch
set inccommand=nosplit

" This shit is NOT laggy in neovim!
set foldmethod=syntax
set foldlevelstart=20

