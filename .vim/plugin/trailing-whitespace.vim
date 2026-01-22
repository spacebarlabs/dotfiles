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

" =============================================================================
" TESTS
" =============================================================================
function! Test_TrailingWhitespace()
  let l:errors = []

  " Test Case 1: db/structure.sql should be excluded
  let l:path = '/some/project/db/structure.sql'
  if l:path !~# 'db/structure\.sql$'
    call add(l:errors, "[DB Structure] Expected db/structure.sql to match exclusion pattern")
  endif

  " Test Case 2: Regular files should not match exclusion
  let l:path = '/some/project/app/model.rb'
  if l:path =~# 'db/structure\.sql$'
    call add(l:errors, "[Regular File] Expected regular file to NOT match exclusion pattern")
  endif

  " Test Case 3: Similar named files should not match
  let l:path = '/some/project/db/structure.sql.backup'
  if l:path =~# 'db/structure\.sql$'
    call add(l:errors, "[Backup File] Expected backup file to NOT match exclusion pattern")
  endif

  " Test Case 4: Case sensitivity check (structure.SQL vs structure.sql)
  let l:path = '/some/project/db/structure.SQL'
  if l:path =~# 'db/structure\.sql$'
    call add(l:errors, "[Case Sensitive] Expected uppercase .SQL to NOT match (case-sensitive)")
  endif

  " Test Case 5: Nested db/structure.sql should match
  let l:path = '/project/nested/path/db/structure.sql'
  if l:path !~# 'db/structure\.sql$'
    call add(l:errors, "[Nested Path] Expected nested db/structure.sql to match exclusion pattern")
  endif

  " Test Case 6: Trailing whitespace regex pattern tests
  let l:line_with_trailing = 'hello world   '
  if l:line_with_trailing !~ '\s\+$'
    call add(l:errors, "[Trailing WS] Expected line with trailing spaces to match pattern")
  endif

  let l:line_without_trailing = 'hello world'
  if l:line_without_trailing =~ '\s\+$'
    call add(l:errors, "[No Trailing WS] Expected line without trailing spaces to NOT match pattern")
  endif

  if len(l:errors) > 0
    throw join(l:errors, " | ")
  endif
endfunction
