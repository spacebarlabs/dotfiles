" =============================================================================
" NETRW CONFIGURATION - File browser (replacement for NERDTree)
" =============================================================================
let g:netrw_banner = 0          " Hide the banner
let g:netrw_liststyle = 3       " Tree view
let g:netrw_browse_split = 4    " Open in previous window and close netrw
let g:netrw_altv = 1            " Open vertical splits to the right when using v
let g:netrw_winsize = 25        " Width of the explorer (25%)
" Toggle Netrw (Lexplore) with backslash
map \ :Lexplore<CR>
