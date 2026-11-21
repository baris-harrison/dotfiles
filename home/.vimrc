" Minimal vim: sane defaults, indentation per file type.
set nocompatible
filetype plugin indent on
syntax on

set mouse=a
set title
set number
set incsearch hlsearch ignorecase smartcase
set backspace=indent,eol,start
set undofile undodir=~/.local/state/vim/undo//
silent! call mkdir(expand('~/.local/state/vim/undo'), 'p')

" Default: 4-space indent with spaces
set expandtab tabstop=4 shiftwidth=4 softtabstop=4

augroup indent_by_filetype
  autocmd!
  autocmd FileType yaml,json,terraform,hcl,sh,bash,zsh,markdown,toml
        \ setlocal tabstop=2 shiftwidth=2 softtabstop=2
  autocmd FileType python setlocal tabstop=4 shiftwidth=4 softtabstop=4
  autocmd FileType make,gitconfig setlocal noexpandtab
augroup END

" vim has no built-in terraform type
autocmd BufNewFile,BufRead *.tf,*.tfvars,*.hcl setfiletype terraform
