" Must be first. Resets vim to default settings, fixing vi bugs.
set nocompatible

if (has("termguicolors"))
  set termguicolors
endif

" Directories for swp files
set backupdir=~/.vim/backup
set directory=~/.vim/backup
" Create directories if they don't exist
if !isdirectory(&backupdir) | call mkdir(&backupdir, "p") | endif
if !isdirectory(&directory) | call mkdir(&directory, "p") | endif

" =============================================================================
" PLUGINS
" =============================================================================
"
" Plugins are managed as git submodules in .vim/pack/plugins/start/
" They are automatically loaded by Vim's native package management

" Enable filetype detection, plugins, and indenting
filetype plugin indent on

" =============================================================================
" EDITOR SETTINGS
" =============================================================================
set number
set ruler
set lazyredraw        " Don't update screen during macros
set showcmd           " Show incomplete commands

" Whitespace & Indentation
set smartindent
set nowrap                      " Don't wrap lines by default
set tabstop=2 shiftwidth=2      " Tab is two spaces
set expandtab                   " Use spaces, not tabs
set backspace=indent,eol,start  " Backspace through everything

" Wrapping (visual only)
set showbreak=...
set wrap linebreak nolist

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Buffers & Status
set hidden
set laststatus=2
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" Wildmenu (command line completion)
set wildmode=list:longest
set wildmenu

" Theme
syntax enable
try
  colorscheme dracula
catch
  colorscheme default
endtry

" Fix truecolor bug for vim if needed
if has('termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" =============================================================================
" MAPPINGS
" =============================================================================
let mapleader=","

" GitGutter
set signcolumn=yes

" =============================================================================
" CONFIGURATION & AUTOCOMMANDS
" =============================================================================

" CtrlP
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" Security
set exrc
set secure

set noerrorbells
set novisualbell

" ========
" Org-Mode
" ========

" === Dynamic Agenda Discovery ===
" 1. Initialize empty list
let g:org_agenda_files = []

" 2. Find all directories ending in .orgmode inside ~/git
"    (Change '~/git' if you move your code folder)
let s:org_repos = glob('~/git/*.orgmode', 0, 1)

" 3. Loop through repos and add only the active GTD files
for repo in s:org_repos
  for filename in ['inbox.org', 'projects.org', 'tickler.org']
    let s:path = repo . '/' . filename
    " Only add the file if it actually exists
    if filereadable(expand(s:path))
      call add(g:org_agenda_files, s:path)
    endif
  endfor
endfor

" Cleanup temporary variables to keep global scope clean
unlet s:org_repos
if exists('s:path')
  unlet s:path
endif

let g:org_todo_keywords = [['TODO', 'NEXT', 'WAITING', '|', 'DONE', 'CANCELLED']]
let g:org_heading_shade_leading_stars = 1
