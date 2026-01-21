if (has("termguicolors"))
  set termguicolors
endif

call plug#begin('~/.vim/plugged')

" Make sure you use single quotes

Plug 'https://github.com/sheerun/vim-polyglot'

Plug 'https://github.com/airblade/vim-gitgutter'
Plug 'https://github.com/bkad/CamelCaseMotion'
Plug 'https://github.com/chrisbra/csv.vim'
Plug 'https://github.com/dense-analysis/ale'
Plug 'https://github.com/ctrlpvim/ctrlp.vim'
Plug 'https://github.com/MarcWeber/vim-addon-mw-utils' " likely dependency
Plug 'https://github.com/mmai/wikilink'
Plug 'https://github.com/kana/vim-textobj-user' " for vim-textobj-rubyblock
Plug 'https://github.com/nelstrom/vim-textobj-rubyblock'
Plug 'https://github.com/pbrisbin/vim-mkdir' " NOTE: As of early 2026, this is moving off GitHub but hasn't fully relocated yet
Plug 'https://github.com/scrooloose/nerdtree'
Plug 'https://github.com/tomtom/tlib_vim' " likely dependency
Plug 'https://github.com/tpope/vim-abolish' " Want to turn fooBar into foo_bar? Press crs (coerce to snake_case). MixedCase (crm), camelCase (crc), UPPER_CASE (cru), dash-case (cr-), and dot.case (cr.) are all just 3 keystrokes away.
Plug 'https://github.com/tpope/vim-commentary.git' "  Use gcc to comment out a line (takes a count), gc to comment out the target of a motion (for example, gcap to comment out a paragraph), gc in visual mode to comment out the selection, and gc in operator pending mode to target a comment.
Plug 'https://github.com/tpope/vim-endwise'
Plug 'https://github.com/tpope/vim-fugitive'
Plug 'https://github.com/tpope/vim-git'
Plug 'https://github.com/tpope/vim-rails'
Plug 'https://github.com/tpope/vim-repeat'
Plug 'https://github.com/tpope/vim-surround'
Plug 'https://github.com/tsaleh/vim-align'
Plug 'https://github.com/vim-scripts/DeleteTrailingWhitespace'
Plug 'https://github.com/vim-scripts/ShowTrailingWhitespace'
Plug 'https://github.com/prabirshrestha/vim-lsp'

Plug 'https://github.com/nathangrigg/vim-beancount'
Plug 'https://github.com/dracula/vim', { 'as': 'dracula' }

if filereadable(glob("~/.vim/local/vimplug"))
  source ~/.vim/local/vimplug
endif

" Initialize plugin system
call plug#end()

" Don't emulate vi bugs (must be first; has side effects)
set nocompatible

set number
set ruler
set lazyredraw " Don't try to continuously update the screen during macros (makes things go faster)

set smartindent

"" Whitespace
set nowrap                      " don't wrap lines
set tabstop=2 shiftwidth=2      " a tab is two spaces
set expandtab                   " use spaces, not tabs
set backspace=indent,eol,start  " backspace through everything in insert mode

" load the plugin and indent settings for the detected filetype
filetype plugin indent on

" Directories for swp files
set backupdir=~/.vim/backup
set directory=~/.vim/backup

" Wrapping
set showbreak=...
set wrap linebreak nolist

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Buffers
set hidden

" Status bar
set laststatus=2
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)
set showcmd

if has("autocmd")
  " In Makefiles, use real tabs, not tabs expanded to spaces
  au FileType make set noexpandtab

  " @see http://www.codeography.com/2010/07/13/json-syntax-highlighting-in-vim.html
  autocmd BufNewFile,BufRead *.json set ft=javascript

  " Make sure markdown files use markdown mode and enable spell checking
  au BufNewFile,BufRead *.{md,markdown} setfiletype markdown
  au BufNewFile,BufRead *.{md,markdown} setlocal spell

  " Enable spell checking for git commits
  au FileType gitcommit setlocal spell

  " Resize splits when window size changes
  au VimResized * exe "normal! \<c-w>="

  " Remember last location in file, but not for commit messages.
  " see :help last-position-jump
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"" | endif
endif

" use comma as <Leader> key instead of backslash
let mapleader=","

" double percentage sign in command mode is expanded
" to directory of current file - http://vimcasts.org/e/14
cnoremap %% <C-R>=expand('%:h').'/'<cr>

" Based on http://robots.thoughtbot.com/faster-grepping-in-vim
" bind K to grep word under cursor
" nnoremap K :Ggrep "\b<C-R><C-W>\b"<CR>:cw<CR>
map K <Nop>

set wildmode=list:longest   "make cmdline tab completion similar to bash
set wildmenu                "enable ctrl-n and ctrl-p to scroll thru matches

" if has('termguicolors')
"   " fix truecolor bug for vim
"   let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
"   let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
"   set termguicolors
" endif

syntax enable
colorscheme dracula

let g:ShowTrailingWhitespace = 1
highlight ShowTrailingWhitespace ctermbg=Red guibg=Red
let g:DeleteTrailingWhitespace = 1
autocmd BufRead,BufNewFile db/structure.sql let g:DeleteTrailingWhitespace = 0
let g:DeleteTrailingWhitespace_Action = 'delete'

" Enable per-directory .vimrc files, but don't allow insecure commands.
set exrc
set secure

" bind nerdtree to \
map \ :NERDTreeToggle<CR>

nmap <Leader>l iLorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.<esc>
nmap <Leader>r ggIRefactor: <esc>
nmap <Leader>f i#{__FILE__}:#{__LINE__} <esc>
nmap <Leader>x 0f[lrx
map <Leader>i YPIputs "<esc>A: #{(<esc>JxA)}"<esc>hi.inspect<esc>0j

vmap <Leader>z :call I18nTranslateString()<CR>

" Replace double quotes with single quotes on the current line.
nmap <Leader>' :.s/"/'/g<CR>:nohlsearch<CR>
nmap <Leader>" :.s/'/"/g<CR>:nohlsearch<CR>

" Change 1.8 hash syntax on the current line to 1.9.
" NB: this isn't perfect, but it's pretty good.
" List of valid symbol chars: https://gist.github.com/misfo/1072693
map <Leader>9 :.s/:\([_a-z0-9]\{1,}\) *=>/\1:/g<CR>:nohlsearch<CR>

" Set a toggle for pastemode
map <Leader>p :set paste!<CR>

" Rename current file. Hit enter after adjusting file name. Will reload vim
" buffer
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

" Auto-save
set updatetime=100 " needed for the next bit
autocmd CursorHold * update " https://vi.stackexchange.com/questions/74/is-it-possible-to-make-vim-auto-save-files

" https://www.rockyourcode.com/vim-trick-map-ctrl-s-to-save/
nnoremap <silent><c-s> :<c-u>update<cr>
vnoremap <silent><c-s> <c-c>:update<cr>gv
inoremap <silent><c-s> <c-o>:update<cr>

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

" Use vim-style binding for Y, unlike nvim which does y$
map Y yy

" Same as o, but doesn't leave you in insert.  Really nice for spacing code out.
noremap - o<esc>
noremap _ O<esc>

"
" ###########
" linters
"
" See also: https://github.com/standardrb/standard/wiki/IDE:-vim
" Use standard if available
if executable('standardrb')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'standardrb',
        \ 'cmd': ['standardrb', '--lsp'],
        \ 'allowlist': ['ruby'],
        \ })
endif
let g:ale_linters = {'ruby': ['standardrb']}
let g:ale_fixers = {'ruby': ['standardrb']}

let g:ale_fix_on_save = 0
let g:ruby_indent_assignment_style = 'variable'
let g:ruby_indent_hanging_elements = 0

" disable diagnotic annotations in LSP, which is separate from ale
" let g:lsp_diagnostics_enabled = 0         " disable diagnostics support

" function! AleOff()
"     let g:ale_linters = {}
"     let g:ale_fixers = {}
" endfunction
"
" :command! -nargs=0 AleOff :call AleOff()
"
" function! AleOn()
"     let g:ale_linters = {'ruby': ['standardrb']}
"     let g:ale_fixers = {'ruby': ['standardrb']}
" endfunction
"
" :command! -nargs=0 AleOn :call AleOn()

" TODO: clean this up
" let g:ale_scss_stylelint_executable = 'stylelint'
"
" let g:ale_javascript_eslint_executable = 'eslint'
"
" let g:ale_eruby_ruumba_executable = 'bundle'
" let g:ale_eruby_ruumba_options = '-e'
"
" let g:ale_ruby_ruby_executable = 'ruby'
" let g:ale_ruby_rubocop_executable = 'bundle'
"
" let g:ale_linters = {
"       \'ruby': ['rubocop', 'ruby'],
"       \'eruby': ['erubi', 'ruumba'],
"       \'javascript': ['eslint'],
"       \'scss': ['stylelint'],
"       \}
"
" let g:ale_fixers = {
"       \'*': ['remove_trailing_lines'],
"       \'javascript': ['eslint'],
"       \'scss': ['stylelint'],
"       \'ruby': ['rubocop'],
"       \}
" let g:ale_fix_on_save_ignore = ['stylelint', 'eslint', 'rubocop']
" let g:ale_fix_on_save = 1
"
" /linters
" ###########
"

" gitgutter: make the gutter always show, so it doesn't shift
set signcolumn=yes
" aliases for gitgutter
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

" Re-indent the whole file and go back to where you were
map <leader>= gg=G''

" don't load everything in .git into the ctrl-p buffer
" source: https://medium.com/a-tiny-piece-of-vim/making-ctrlp-vim-load-100x-faster-7a722fae7df6
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

set foldmethod=syntax
" foldevalstart approximates a 'don't automatically fold everything when a file is
" opened' setting
set foldlevelstart=99

" don't hide quoting in json files
" https://github.com/elzr/vim-json#common-problems
let g:vim_json_syntax_conceal = 0

runtime! macros/matchit.vim
