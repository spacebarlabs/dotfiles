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

" =============================================================================
" TESTS
" =============================================================================
function! Test_AutoMkdir()
  let l:errors = []

  " Test Case 1: URL paths should be skipped
  let l:test_dir = 'http://example.com/path/to/file'
  if l:test_dir !~ '://'
    call add(l:errors, "[URL] Expected URL pattern to match '://' but it didn't")
  endif

  " Test Case 2: FTP paths should be skipped
  let l:test_dir = 'ftp://server.com/file'
  if l:test_dir !~ '://'
    call add(l:errors, "[FTP] Expected FTP pattern to match '://' but it didn't")
  endif

  " Test Case 3: Normal paths should not match URL pattern
  let l:test_dir = '/tmp/normal/path'
  if l:test_dir =~ '://'
    call add(l:errors, "[Normal Path] Expected normal path to NOT match '://' but it did")
  endif

  " Test Case 4: Windows-style paths should not match URL pattern
  let l:test_dir = 'C:\Windows\Path'
  if l:test_dir =~ '://'
    call add(l:errors, "[Windows Path] Expected Windows path to NOT match '://' but it did")
  endif

  if len(l:errors) > 0
    throw join(l:errors, " | ")
  endif
endfunction
