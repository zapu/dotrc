syntax on

" Stuff to make git commits look good
" gitcommit syntax colours first and second line differently
" textwidth autowraps text after 72 chars
autocmd Filetype gitcommit setlocal textwidth=72
autocmd FileType gitcommit call setpos('.', [0, 1, 1, 0])

" indents, whitespace
set autoindent              " keep indenting on newlines
set tabstop=4               " 
set shiftwidth=4            " one tab = four spaces (autoindent)
set softtabstop=4           " one tab = four spaces (tab key)
set smarttab                " 
set expandtab               " don't use hard tabs

set fileformats=unix,dos    " new files starts with unix linebreaks

set list
set listchars=tab:↹·,extends:⇉,precedes:⇇,nbsp:␠,trail:␠,nbsp:␣

" Search
set ignorecase
set smartcase               " case-ins search, unless there are capitals
set gdefault                " s///g by default