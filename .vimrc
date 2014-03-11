syntax on
filetype on
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set hidden
set ruler
set backspace=indent,eol,start
au BufNewFile,BufRead *.pp set filetype=ruby
au BufNewFile,BufRead *.aug set filetype=ruby
if has("mouse")
    set mouse=a
    set mousehide
endif
set clipboard=unnamedplus
