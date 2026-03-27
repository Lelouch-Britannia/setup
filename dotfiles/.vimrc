call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-sensible'	" Good default setting
Plug 'tpope/vim-commentary'	" Comment/uncomment using gc
Plug 'vim-airline/vim-airline'	" Status bar
Plug 'preservim/nerdtree'	" File explorer
Plug 'junegunn/fzf.vim'         " Fuzzy file finder (requires fzf)

call plug#end()

" === General Settings ===
syntax on                    " Enable syntax highlighting
set number                   " Show line numbers
set relativenumber           " Relative line numbers
set expandtab shiftwidth=4   " Use spaces instead of tabs
set tabstop=4                " Display width of tab
set smartindent              " Auto-indent new lines
set cursorline               " Highlight the current line
set nowrap                   " Disable line wrapping

" === Keybindings ===
nnoremap <C-n> :NERDTreeToggle<CR>

" ===Airline Config ===
let g:airline#extensions#tabline#enabled = 1
