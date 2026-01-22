set nocompatible

" Use Absolute Path for reliability in CI
let s:repo_root = getcwd()
let &rtp = s:repo_root . '/.vim,' . &rtp

" Force output to stdout for CI visibility
function! Log(msg)
  call writefile([a:msg], "/dev/stdout", "a")
endfunction

call Log("🔍  Repo Root: " . s:repo_root)
call Log("🔍  RuntimePath: " . &rtp)

" Explicitly glob to see if Vim can actually find the files
let s:plugin_files = globpath(&rtp, 'plugin/**/*.vim', 0, 1)
call Log("📂  Found plugin files: " . string(s:plugin_files))

" Source them
runtime! plugin/**/*.vim

" Find tests
let s:test_functions = getcompletion('Test_', 'function')
let s:total_failures = 0

if len(s:test_functions) == 0
  call Log("⚠️  No tests found! Check file paths above.")
  cquit
endif

" Run tests
for func in s:test_functions
  call Log("🏃 Running suite: " . func . "...")
  try
    call call(func, [])
  catch
    call Log("❌ CRITICAL FAILURE in " . func . ": " . v:exception)
    let s:total_failures += 1
  endtry
endfor

if s:total_failures > 0
  call Log("💀 FAILED: " . s:total_failures . " test suites crashed.")
  cquit
else
  call Log("✅ All test suites completed successfully.")
  qall!
endif
