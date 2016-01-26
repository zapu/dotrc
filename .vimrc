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

" Soft word wrapping
set wrap
set linebreak
" jk will traver through soft lines instead of hard lines
nnoremap j gj
nnoremap k gk
vnoremap j gj
vnoremap k gkk

" Search
set ignorecase
set smartcase               " case-ins search, unless there are capitals
set gdefault                " s///g by default

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("win32")
    set background=light
    color solarized 

    if has("gui_running")
        " Set a nicer font.
        set guifont=DejaVu\ Sans\ Mono:h10:cDEFAULT
        " Hide the toolbar.
        set guioptions-=T    

        set lines=50
        set columns=90

        command Open browse confirm open
        command Save browse confirm saveas
    endif

    " redefine new files
    set fileformats=dos,unix

    set nolist " ?
else
    " linux
    set list
    set listchars=tab:↹·,extends:⇉,precedes:⇇,nbsp:␠,trail:␠,nbsp:␣
endif
