" An example for a vimrc file.
"
" To use it, copy it to "     for Unix and OS/2:  ~/.vimrc
"	      for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"	    for OpenVMS:  sys$login:.vimrc

" When started as "evim", evim.vim will already have done these settings, bail
" out.
if v:progname =~? "evim"
  finish
endif

" Get the defaults that most users want.
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

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif
runtime macros/matchit.vim

" Plugins will be downloaded under the specified directory.
call plug#begin('~/.vim/plugged')

" Declare the list of plugins.
Plug 'JuliaEditorSupport/julia-vim'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-commentary'
" Plug 'vim-airline/vim-airline'
" Plug 'vim-airline/vim-airline-themes'

" List ends here. Plugins become visible to Vim after this call.
call plug#end()

" change .un~ ~ .swp directories
set backupdir=~/.vim/.backup/,/tmp//
set directory=~/.vim/.swp/,/tmp//
set undodir=~/.vim/.undo/,/tmp//

" custom setups
set nu!
hi LineNr ctermfg=grey
fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun
autocmd FileType c,cpp,python,julia,vim,markdown
	\ autocmd BufWritePre * call TrimWhitespace()

" airline
" set noshowmode
" let g:airline_theme='simple'
" let g:airline_section_z = '%3l:%v %3L '
" let g:airline_mode_map = {
" 	\ '__'     : '-',
" 	\ 'c'      : 'C',
" 	\ 'i'      : 'I',
" 	\ 'ic'     : 'I',
" 	\ 'ix'     : 'I',
" 	\ 'n'      : 'N',
" 	\ 'multi'  : 'M',
" 	\ 'ni'     : 'N',
" 	\ 'no'     : 'N',
" 	\ 'R'      : 'R',
" 	\ 'Rv'     : 'R',
" 	\ 's'      : 'S',
" 	\ 'S'      : 'S',
" 	\ ''     : 'S',
" 	\ 't'      : 'T',
" 	\ 'v'      : 'V',
" 	\ 'V'      : 'V',
" 	\ ''     : 'V',
" 	\ }
" let g:airline#parts#ffenc#skip_expected_string='utf-8[unix]'
" let g:airline#extensions#whitespace#checks = [ 'indent', 'long', 'conflicts' ]
" let g:airline_skip_empty_sections = 1
" hi airline_c  ctermbg=NONE guibg=NONE
" let g:airline#extensions#whitespace#checks =
"     \  [ 'indent', 'trailing', 'long', 'mixed-indent-file', 'conflicts' ]
