set nocompatible

" 1. Add .vim directory to path so it picks up plugins
set rtp+=.vim

" 2. Source all files in .vim/plugin
runtime! plugin/**/*.vim

echo "Search patterns: Test_*"

" 3. Find all global functions starting with 'Test_'
let s:test_functions = getcompletion('Test_', 'function')
let s:total_failures = 0

if len(s:test_functions) == 0
  echo "⚠️  No tests found! (Did you name your functions Test_...?)"
  cquit
endif

" 4. Run each test suite
for func in s:test_functions
  echo "🏃 Running suite: " . func . "..."
  try
    call call(func, [])
  catch
    echo "❌ CRITICAL FAILURE in " . func . ": " . v:exception
    let s:total_failures += 1
  endtry
endfor

if s:total_failures > 0
  echo "FAILED: " . s:total_failures . " test suites crashed."
  cquit
else
  echo "✅ All test suites completed."
  qall!
endif
