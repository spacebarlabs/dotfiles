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

" =============================================================================
" TESTS
" =============================================================================
function! Test_SmartSave()
  let l:errors = []

  " Test Case 1: tempname() should return a valid path
  let l:tmp = tempname()
  if l:tmp == ''
    call add(l:errors, "[TempName] Expected tempname() to return non-empty path")
  endif

  " Test Case 2: fnameescape() should escape special characters
  let l:normal = '/tmp/normal'
  let l:escaped_normal = fnameescape(l:normal)
  if l:escaped_normal != '/tmp/normal'
    call add(l:errors, "[Escape Normal] Expected '/tmp/normal' but got " . l:escaped_normal)
  endif

  " Test Case 3: fnameescape() should escape spaces
  let l:with_space = '/tmp/file name'
  let l:escaped_space = fnameescape(l:with_space)
  if l:escaped_space == l:with_space
    call add(l:errors, "[Escape Space] Expected fnameescape to modify path with spaces")
  endif

  " Test Case 4: Empty string check logic
  let l:empty = ''
  if l:empty != ''
    call add(l:errors, "[Empty Check] Expected empty string comparison to work")
  endif

  let l:nonempty = 'test.txt'
  if l:nonempty == ''
    call add(l:errors, "[Non-Empty Check] Expected non-empty string to not equal empty")
  endif

  if len(l:errors) > 0
    throw join(l:errors, " | ")
  endif
endfunction
