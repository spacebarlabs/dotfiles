" =============================================================================
" UTILITY MAPPINGS AND ABBREVIATIONS
" =============================================================================

" Quick helpers
cnoremap %% <C-R>=expand('%:h').'/'<cr>
map K <Nop>

" Indentation: Re-indent whole file and jump back
map <leader>= gg=G''

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
nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)

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
