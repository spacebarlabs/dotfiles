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

    " Switch to Warning highlight group
    echohl WarningMsg
    echo "Saved to temp file: " . l:tmp
    " Reset highlighting
    echohl None
  else
    update
  endif
endfunction

nnoremap <silent><c-s> :call SmartSave()<cr>
vnoremap <silent><c-s> <c-c>:call SmartSave()<cr>gv
inoremap <silent><c-s> <c-o>:call SmartSave()<cr>
