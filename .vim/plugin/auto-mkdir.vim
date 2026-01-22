" =============================================================================
" AUTO MKDIR
" =============================================================================
" Automatically create parent directories when saving files
if has("autocmd")
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
endif
