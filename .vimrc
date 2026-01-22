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

" Netrw - File browser (replacement for NERDTree)
let g:netrw_banner = 0          " Hide the banner
let g:netrw_liststyle = 3       " Tree view
let g:netrw_browse_split = 4    " Open in previous window and close netrw
let g:netrw_altv = 1            " Open vertical splits to the right when using v
let g:netrw_winsize = 25        " Width of the explorer (25%)
" Toggle Netrw (Lexplore) with backslash
map \ :Lexplore<CR>

" Quick helpers
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map K <Nop>

" Indentation: Re-indent whole file and jump back
map <leader>= gg=G''

" =============================================================================
" SMART SAVE (Ctrl-S)
" =============================================================================
" If file has a name, update it.
" If not, save it as a temp file so subsequent saves update that temp file.
function! SmartSave()
  if expand('%') == ''
    let l:tmp = tempname()
    execute 'saveas ' . fnameescape(l:tmp)
    redraw!
    echo "Saved to temp file: " . l:tmp
  else
    update
  endif
endfunction

nnoremap <silent><c-s> :call SmartSave()<cr>
vnoremap <silent><c-s> <c-c>:call SmartSave()<cr>gv
inoremap <silent><c-s> <c-o>:call SmartSave()<cr>

" Utility Mappings
nmap <Leader>l iLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.<esc>
nmap <Leader>r ggIRefactor: <esc>
nmap <Leader>f i#{__FILE__}:#{__LINE__} <esc>
nmap <Leader>x 0f[lrx
map <Leader>i YPIputs "<esc>A: #{(<esc>JxA)}"<esc>hi.inspect<esc>0j
vmap <Leader>z :call I18nTranslateString()<CR>

" Quote switching
nmap <Leader>' :.s/"/'/g<CR>:nohlsearch<CR>
nmap <Leader>" :.s/'/"/g<CR>:nohlsearch<CR>

" Ruby 1.8 -> 1.9 hash syntax
map <Leader>9 :.s/:\([_a-z0-9]\{1,}\) *=>/\1:/g<CR>:nohlsearch<CR>

" Toggle paste mode
map <Leader>p :set paste!<CR>

" GitGutter
set signcolumn=yes
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

" Rename File
function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'))
    if new_name != '' && new_name != old_name
      exec ':saveas ' . new_name
      exec ':silent !rm ' . old_name
      redraw!
    endif
endfunction
map <leader>mv :call RenameFile()<cr>

" Insert newline without entering insert mode
noremap - o<esc>
noremap _ O<esc>

" Use Vim-style Y (yank line)
map Y yy

" Abbreviations
abbrev buig bug
abbrev contorl control
abbrev flase false
abbrev frmo from
abbrev hte the
abbrev jsut just
abbrev nad and
abbrev ptus puts
abbrev teamplate template
abbrev teh the
abbrev tempalte template
abbrev TOOD TODO
abbrev ture true
abbrev yuo you

" =============================================================================
" CONFIGURATION & AUTOCOMMANDS
" =============================================================================

" CtrlP
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" Show trailing whitespace with builtin match feature
highlight TrailingWhitespace ctermbg=Red guibg=Red
autocmd BufWinEnter * match TrailingWhitespace /\s\+$/
" In insert mode, don't highlight trailing whitespace at cursor position
" \%# matches cursor position, \@<! is negative lookbehind
autocmd InsertEnter * match TrailingWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match TrailingWhitespace /\s\+$/

" Delete trailing whitespace on save with builtin autocommand
" Exclude db/structure.sql files (they may have intentional trailing whitespace)
autocmd BufWritePre * if expand('%:p') !~# 'db/structure\.sql$' | %s/\s\+$//e | endif

" vim-lsp Settings
if executable('standardrb')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'standardrb',
        \ 'cmd': ['standardrb', '--lsp'],
        \ 'allowlist': ['ruby'],
        \ })
endif

" Enable format on save for vim-lsp
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  augroup lsp_format_on_save
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> LspDocumentFormatSync
  augroup END
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let g:ruby_indent_assignment_style = 'variable'
let g:ruby_indent_hanging_elements = 0

" Security
set exrc
set secure

" Auto-save
set updatetime=100
autocmd CursorHold * update

" Folding
set foldmethod=syntax
set foldlevelstart=99
runtime! macros/matchit.vim

if has("autocmd")
  " Automatically create parent directories when saving files
  function! s:Mkdir()
    let dir = expand('%:p:h')
    if dir =~ '://'
      return
    endif
    if !isdirectory(dir)
      call mkdir(dir, 'p')
      echo 'Created non-existing directory: '.dir
    endif
  endfunction
  autocmd BufWritePre * call s:Mkdir()

  " Makefiles
  au FileType make set noexpandtab

  " Markdown
  au BufNewFile,BufRead *.{md,markdown} setfiletype markdown
  au BufNewFile,BufRead *.{md,markdown} setlocal spell

  " Markdown fenced code block syntax highlighting
  let g:markdown_fenced_languages = [
    \ 'ruby',
    \ 'erb=eruby',
    \ 'javascript',
    \ 'js=javascript',
    \ 'json',
    \ 'css',
    \ 'sass',
    \ 'scss=sass',
    \ 'html',
    \ 'bash=sh',
    \ 'sh',
    \ 'sql',
    \ 'xml',
    \ 'python',
    \ 'ts=typescript',
    \ 'typescript',
    \ 'yaml',
    \ 'go',
    \ 'vim',
    \ 'diff'
  \ ]
  
  " Prevent Vim from hiding formatting characters (like * or _)
  let g:markdown_syntax_conceal = 0

  " Git commits
  au FileType gitcommit setlocal spell

  " Resize splits when window size changes
  au VimResized * exe "normal! \<c-w>="

  " Remember last location in file
  " (Checks if filetype is NOT git commit, then jumps to last known cursor position)
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"" | endif
endif
