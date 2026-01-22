" =============================================================================
" TRAILING WHITESPACE
" =============================================================================
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
