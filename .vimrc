"  .vimrc
set directory=~/.vim/backup,/tmp
set number
set mouse=a
set ruler
set showmatch
set hlsearch
set incsearch
set ignorecase
set smartcase
set tabstop=3
set shiftwidth=3
set expandtab
set autoindent
set smartindent

"Status Line
set laststatus=2
set statusline=%f\ %y\ %m%r%h%w
set statusline+=%=
set statusline+=[L:\ %l/%L]\ [C:\ %v]\ [%p%%]

if $TERM == 'screen'
  set term=rxvt-unicode
endif

filetype plugin indent on
syntax on
