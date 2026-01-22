" ==============================================================================
"  LLM Git Commit Generator
" ==============================================================================
"
"  PREREQUISITES:
"    1. Install Ollama: https://ollama.com
"    2. Pull a fast model:
"         ollama pull qwen2.5-coder:1.5b
"
" ==============================================================================

if !exists('g:llm_host')
  let g:llm_host = 'http://localhost:11434'
endif

if !exists('g:llm_model')
  " let g:llm_model = 'qwen2.5-coder:1.5b'
  let g:llm_model = 'phi3'
endif

" --- Core Logic: Noise Filter ---
function! s:FilterLines(lines)
  let l:clean_lines = []

  for line in a:lines
    " A. Remove Git Status Comments
    if line =~ '^#'
      continue
    endif

    " B. Remove Empty Lines
    if line =~ '^[+\- ]\?\s*$'
      continue
    endif

    " C. Remove Structural Noise
    " 1. Keywords (end, endif, etc)
    " FIX: Use \< and \> for word boundaries instead of \b
    if line =~ '^[+\- ]\?\s*\<\(end\|endif\|endfunction\|endfor\|endwhile\|endtry\|fi\|esac\|done\)\>\s*$'
      continue
    endif

    " 2. Code Symbols: }, ], ), };
    " FIX: ] is first in the set to avoid regex parsing errors
    if line =~ '^[+\- ]\?\s*[\]})]\+;\?\s*$'
      continue
    endif

    " 3. HTML/XML closing tags
    if line =~ '^[+\- ]\?\s*</[a-zA-Z0-9\-_]\+>\s*$'
      continue
    endif

    call add(l:clean_lines, line)
  endfor

  return l:clean_lines
endfunction

" --- Strip Wrapping Characters ---
function! s:StripWrapping(text)
  let l:cleaned = a:text
  
  " Remove leading/trailing whitespace
  let l:cleaned = substitute(l:cleaned, '^\s\+', '', '')
  let l:cleaned = substitute(l:cleaned, '\s\+$', '', '')
  
  " Remove wrapping backticks (single or triple)
  " Match ```...``` or `...`
  " Use \_. to match any character including newlines
  let l:cleaned = substitute(l:cleaned, '^```\(\_.*\)```$', '\1', '')
  let l:cleaned = substitute(l:cleaned, '^`\(\_.*\)`$', '\1', '')
  
  " Remove wrapping quotes (single or double)
  " Use \_. to match any character including newlines
  let l:cleaned = substitute(l:cleaned, '^"\(\_.*\)"$', '\1', '')
  let l:cleaned = substitute(l:cleaned, "^'\\(\\_.*\\)'$", '\1', '')
  
  " Remove leading/trailing whitespace again after removing wrappers
  let l:cleaned = substitute(l:cleaned, '^\s\+', '', '')
  let l:cleaned = substitute(l:cleaned, '\s\+$', '', '')
  
  return l:cleaned
endfunction

" --- Main Function ---
function! GenerateCommitMsg()
  let l:ping_cmd = 'curl -s -o /dev/null -w "%{http_code}" --connect-timeout 0.1 ' . g:llm_host
  let l:ping = system(l:ping_cmd)

  if l:ping != "200"
    echo "Ollama is offline. Skipping AI generation."
    return
  endif

  echo "Generating commit message..."

  let l:buffer_lines = getline(1, 2000)
  let l:clean_lines = s:FilterLines(l:buffer_lines)
  let l:diff_content = join(l:clean_lines, "\n")

  if len(l:diff_content) < 10
    return
  endif

  let l:system_prompt = "Generate a single, concise git commit message (Conventional Commits) for this diff. No explanations, no quotes. First line is the subject, optional body after a blank line."

  let l:payload = {
  \ 'model': g:llm_model,
  \ 'prompt': l:system_prompt . "\n\n" . l:diff_content,
  \ 'stream': v:false,
  \ 'options': {'temperature': 0.2}
  \ }

  let l:json_body = json_encode(l:payload)
  let l:tmp_file = tempname()
  call writefile([l:json_body], l:tmp_file)

  let l:curl_cmd = 'curl -s -X POST ' . g:llm_host . '/api/generate -d @' . l:tmp_file
  let l:response_raw = system(l:curl_cmd)
  call delete(l:tmp_file)

  try
    let l:response_json = json_decode(l:response_raw)
    if has_key(l:response_json, 'response')
      let l:msg = l:response_json.response
      let l:msg = s:StripWrapping(l:msg)
      call append(0, split(l:msg, "\n"))
      normal! gg
    endif
  catch
  endtry
endfunction

augroup LLMCommit
  autocmd!
  autocmd FileType gitcommit if getline(1) == '' | call GenerateCommitMsg() | endif
augroup END

command! GitCommit call GenerateCommitMsg()

" ==============================================================================
"  TEST SUITE
" ==============================================================================
function! Test_LLMCommit()
  let l:errors = []

  " Test Case 1: Ruby Noise
  let l:input = ['def hello', '  puts "hi"', 'end', '+ end']
  let l:expected = ['def hello', '  puts "hi"']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected
    call add(l:errors, "[Ruby] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif

  " Test Case 2: JS Noise
  let l:input = ['function x() {', '  return 1;', '}', '};']
  let l:expected = ['function x() {', '  return 1;']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected
    call add(l:errors, "[JS] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif

  " Test Case 3: HTML Noise
  let l:input = ['<div>', '  Hello', '</div>', '   </p>']
  let l:expected = ['<div>', '  Hello']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected
    call add(l:errors, "[HTML] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif

  " Test Case 4: Git Comments & Whitespace
  let l:input = ['# This is a comment', '', '  ', '+ valid code']
  let l:expected = ['+ valid code']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected
    call add(l:errors, "[Comments] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif

  if len(l:errors) > 0
    throw join(l:errors, " | ")
  endif
endfunction

" Test the StripWrapping function
function! Test_StripWrapping()
  let l:errors = []
  
  " Test Case 1: Backticks (single)
  let l:input = '`fix: update config`'
  let l:expected = 'fix: update config'
  let l:actual = s:StripWrapping(l:input)
  if l:actual != l:expected
    call add(l:errors, "[Backticks] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif
  
  " Test Case 2: Triple backticks
  let l:input = '```feat: add new feature```'
  let l:expected = 'feat: add new feature'
  let l:actual = s:StripWrapping(l:input)
  if l:actual != l:expected
    call add(l:errors, "[Triple Backticks] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif
  
  " Test Case 3: Double quotes
  let l:input = '"refactor: improve performance"'
  let l:expected = 'refactor: improve performance'
  let l:actual = s:StripWrapping(l:input)
  if l:actual != l:expected
    call add(l:errors, "[Double Quotes] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif
  
  " Test Case 4: Single quotes
  let l:input = "'docs: update README'"
  let l:expected = 'docs: update README'
  let l:actual = s:StripWrapping(l:input)
  if l:actual != l:expected
    call add(l:errors, "[Single Quotes] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif
  
  " Test Case 5: No wrapping
  let l:input = 'chore: bump version'
  let l:expected = 'chore: bump version'
  let l:actual = s:StripWrapping(l:input)
  if l:actual != l:expected
    call add(l:errors, "[No Wrapping] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif
  
  " Test Case 6: With leading/trailing whitespace
  let l:input = '  `fix: remove bug`  '
  let l:expected = 'fix: remove bug'
  let l:actual = s:StripWrapping(l:input)
  if l:actual != l:expected
    call add(l:errors, "[Whitespace] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif
  
  " Test Case 7: Multiline with backticks
  let l:input = "`fix: update API\n\nUpdate the API endpoint to handle new cases`"
  let l:expected = "fix: update API\n\nUpdate the API endpoint to handle new cases"
  let l:actual = s:StripWrapping(l:input)
  if l:actual != l:expected
    call add(l:errors, "[Multiline] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif
  
  if len(l:errors) > 0
    throw join(l:errors, " | ")
  endif
endfunction
