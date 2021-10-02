" Zhou Feng @ 2021-10-2
"
"	Unix and MacOS:  ~/.vimrc
"	MS-DOS and Win32:  $VIM\_vimrc

if v:progname =~? "evim"
  finish
endif

" Get the defaults
" source $VIMRUNTIME/defaults.vim

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile	" keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78
augroup END

" change .un~ ~ .swp directories
set backupdir=~/.vim/.backup/,/tmp//
set directory=~/.vim/.swp/,/tmp//
set undodir=~/.vim/.undo/,/tmp//

" line numbers
set rnu!
hi LineNr ctermfg=darkgrey

" whitespace
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
autocmd FileType c,cpp,python,julia,markdown
	\ autocmd BufWritePre * call TrimWhitespace()

" statusline
set laststatus=2
set statusline=
set statusline+=%#StatusLine#
set statusline+=%{FugitiveStatusline()}
" set statusline+=%{fugitive#head()} 
set statusline+=%#LineNr#
set statusline+=\ %f
set statusline+=%m\ 
set statusline+=%=
" set statusline+=%#LineNr#
set statusline+=\ %y
set statusline+=\ %{&fileencoding?&fileencoding:&encoding}
set statusline+=\[%{&fileformat}\]
" set statusline+=%#ModeMsg#
set statusline+=\ %4l,%-2c
set statusline+=\ 


" Add optional packages.
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif
runtime macros/matchit.vim

" Plugins Vim-Plug 
call plug#begin('~/.vim/plugged')
Plug 'JuliaEditorSupport/julia-vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
Plug 'godlygeek/tabular'
Plug 'sirver/ultisnips'
Plug 'lervag/vimtex', { 'for': 'tex' }
Plug 'preservim/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'junegunn/fzf'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'
call plug#end()

" plugin settings
let NERDTreeQuitOnOpen=1
let g:tex_flavor='latex'
let g:vimtex_view_method='zathura'
" let g:vimtex_quickfix_mode=0
" set conceallevel=1
" let g:tex_conceal='abdmg'
"
let g:UltiSnipsExpandTrigger = '<tab>'
let g:UltiSnipsJumpForwardTrigger = '<tab>'
let g:UltiSnipsJumpBackwardTrigger = '<s-tab>'

" keybindings
map <C-n> :NERDTreeToggle<CR>
let mapleader = " "
map <leader>w :w<CR>
map <leader>q :q!<CR>
map <leader>Q :qa!<CR>
map <leader>h :noh<CR>
map <leader>t :NERDTreeToggle<CR>
map <leader>f :FZF<CR>
" map <leader>n :set nonumber<CR>
let mapleader = ","
map <leader>n :set nonumber<CR>
map <leader>q :wq<CR>
