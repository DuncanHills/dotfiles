syntax on
filetype on
set tabstop=4
set shiftwidth=4
set expandtab
set autoindent
set hidden
set backspace=indent,eol,start
au BufNewFile,BufRead *.pp set filetype=ruby
au BufNewFile,BufRead *.aug set filetype=ruby
if has("mouse")
    set mouse=a
    set mousehide
endif
if !empty($powerline_vim)
    set rtp+=$powerline_vim
    " Always show statusline
    set laststatus=2
    " Hide default mode text
    set noshowmode
    " Use 256 colours (Use this setting only if your terminal supports 256 colours)
    set t_Co=256
    if ! has('gui_running')
        set ttimeoutlen=10
        augroup FastEscape
            autocmd!
            au InsertEnter * set timeoutlen=0
            au InsertLeave * set timeoutlen=1000
        augroup END
    endif
else
    set ruler
endif
