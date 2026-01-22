set nocompatible

" 1. Setup Path
let s:repo_root = getcwd()
let &rtp = s:repo_root . '/.vim,' . &rtp

" Helper: Log to stdout for CI
function! Log(msg)
  call writefile([a:msg], "/dev/stdout", "a")
endfunction

call Log("🔍  Repo Root: " . s:repo_root)

" 2. Source Plugins
runtime! plugin/**/*.vim

" 3. Find Tests
let s:test_functions = getcompletion('Test_', 'function')
let s:total_failures = 0

if len(s:test_functions) == 0
  call Log("⚠️  No tests found! (Check if plugin/llm_commit.vim is loading)")
  cquit
endif

" 4. Run Tests
for raw_func in s:test_functions
  " FIX: Strip trailing '()' if present (e.g. 'MyFunc()' -> 'MyFunc')
  let func = substitute(raw_func, '()$', '', '')

  call Log("🏃 Running suite: " . func . "...")
  
  try
    call call(func, [])
  catch
    call Log("❌ CRITICAL FAILURE in " . func . ": " . v:exception)
    let s:total_failures += 1
  endtry
endfor

" 5. Summary
if s:total_failures > 0
  call Log("💀 FAILED: " . s:total_failures . " test suites crashed.")
  cquit
else
  call Log("✅ All test suites completed successfully.")
  qall!
endif
