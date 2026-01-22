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
  let g:llm_model = 'qwen2.5-coder:1.5b'
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
    if line =~ '^[+\- ]\?\s*\b\(end\|endif\|endfunction\|endfor\|endwhile\|endtry\|fi\|esac\|done\)\b\s*$'
      continue
    endif

    " 2. Code Symbols: }, ], ), }; 
    " FIX: ] must be first in the [] set to be matched correctly
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

  " Throw all errors at once so they appear in CI logs
  if len(l:errors) > 0
    throw join(l:errors, " | ")
  endif
endfunction
