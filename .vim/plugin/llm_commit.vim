" ==============================================================================
"  LLM Git Commit Generator
" ==============================================================================
"
"  PREREQUISITES:
"    1. Install Ollama: https://ollama.com
"    2. Pull a fast model:
"         ollama pull qwen2.5-coder:1.5b  (Fastest, recommended)
"         ollama pull phi3                (Smarter, slightly slower)
"
" ==============================================================================

" --- Configuration ---
if !exists('g:llm_host')
  let g:llm_host = 'http://localhost:11434'
endif

if !exists('g:llm_model')
  let g:llm_model = 'qwen2.5-coder:1.5b'
  " let g:llm_model = 'phi3'
endif

" --- Core Logic: Noise Filter ---
function! s:FilterLines(lines)
  let l:clean_lines = []
  
  for line in a:lines
    " A. Remove Git Status Comments (lines starting with #)
    if line =~ '^#'
      continue
    endif
    
    " B. Remove Empty Lines (pure whitespace OR just a diff marker +/- and whitespace)
    if line =~ '^[+\- ]\?\s*$'
      continue
    endif

    " C. Remove Structural Noise
    " 1. Keywords: end, endif, done, fi, esac, etc.
    if line =~ '^[+\- ]\?\s*\b\(end\|endif\|endfunction\|endfor\|endwhile\|endtry\|fi\|esac\|done\)\b\s*$'
      continue
    endif

    " 2. Code Symbols: }, ], ), };
    if line =~ '^[+\- ]\?\s*[}\])]\+;\?\s*$'
      continue
    endif

    " 3. HTML/XML: closing tags like </div>, </p>, </script>, </my-element>
    if line =~ '^[+\- ]\?\s*</[a-zA-Z0-9\-_]\+>\s*$'
      continue
    endif

    call add(l:clean_lines, line)
  endfor
  
  return l:clean_lines
endfunction

" --- Main Function ---
function! GenerateCommitMsg()
  " 1. CHECK: Is Ollama running?
  let l:ping_cmd = 'curl -s -o /dev/null -w "%{http_code}" --connect-timeout 0.1 ' . g:llm_host
  let l:ping = system(l:ping_cmd)
  
  if l:ping != "200"
    echo "Ollama is offline. Skipping AI generation."
    return
  endif

  echo "Generating commit message..."

  " 2. PREPARE: Grab buffer and filter
  let l:buffer_lines = getline(1, 2000)
  let l:clean_lines = s:FilterLines(l:buffer_lines)
  let l:diff_content = join(l:clean_lines, "\n")

  " If diff is empty after filtering, abort
  if len(l:diff_content) < 10
    return
  endif
  
  " 3. PROMPT
  let l:system_prompt = "Generate a single, concise git commit message (Conventional Commits) for this diff. No explanations, no quotes. First line is the subject, optional body after a blank line."
  
  let l:payload = {
  \ 'model': g:llm_model,
  \ 'prompt': l:system_prompt . "\n\n" . l:diff_content,
  \ 'stream': v:false,
  \ 'options': {'temperature': 0.2} 
  \ }
  
  " 4. SEND
  let l:json_body = json_encode(l:payload)
  let l:tmp_file = tempname()
  call writefile([l:json_body], l:tmp_file)
  
  let l:curl_cmd = 'curl -s -X POST ' . g:llm_host . '/api/generate -d @' . l:tmp_file
  let l:response_raw = system(l:curl_cmd)
  call delete(l:tmp_file)

  " 5. INSERT
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

" --- Automation ---
augroup LLMCommit
  autocmd!
  autocmd FileType gitcommit if getline(1) == '' | call GenerateCommitMsg() | endif
augroup END

command! GitCommit call GenerateCommitMsg()

" ==============================================================================
"  TEST SUITE (Discovered via Test_ prefix)
" ==============================================================================
function! Test_LLMCommit()
  let l:failures = 0
  
  " Test Case 1: Ruby Noise
  let l:input = ['def hello', '  puts "hi"', 'end', '+ end']
  let l:expected = ['def hello', '  puts "hi"']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected 
    echo "  Failed Ruby. Got: " . string(l:actual) 
    let l:failures += 1 
  endif

  " Test Case 2: JS Noise
  let l:input = ['function x() {', '  return 1;', '}', '};']
  let l:expected = ['function x() {', '  return 1;']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected 
    echo "  Failed JS. Got: " . string(l:actual) 
    let l:failures += 1 
  endif

  " Test Case 3: HTML Noise
  let l:input = ['<div>', '  Hello', '</div>', '   </p>']
  let l:expected = ['<div>', '  Hello']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected 
    echo "  Failed HTML. Got: " . string(l:actual) 
    let l:failures += 1 
  endif

  " Test Case 4: Git Comments & Whitespace
  let l:input = ['# This is a comment', '', '  ', '+ valid code']
  let l:expected = ['+ valid code']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected 
    echo "  Failed Comments. Got: " . string(l:actual) 
    let l:failures += 1 
  endif

  if l:failures > 0
    throw l:failures . " assertions failed in Test_LLMCommit"
  endif
endfunction
