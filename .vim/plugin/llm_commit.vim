" ==============================================================================
"  LLM Git Commit Generator (VimScript)
" ==============================================================================
"
"  PREREQUISITES:
"    1. Install Ollama: https://ollama.com
"    2. Pull the model: ollama pull qwen2.5-coder:1.5b
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
    " A. Remove Git Status Comments (lines starting with #)
    if line =~ '^#'
      continue
    endif
    
    " B. Remove Context Lines (lines starting with a space)
    "    Git diffs use a leading space for unchanged context.
    "    We want the LLM to only see headers, +, and -.
    if line =~ '^ '
      continue
    endif
    
    " C. Remove Empty Lines
    if line =~ '^[+\- ]\?\s*$'
      continue
    endif

    " D. Remove Structural Noise from Changes
    
    " 1. Keywords (end, endif, etc) - using word boundaries \< \>
    if line =~ '^[+\-]\s*\<\(end\|endif\|endfunction\|endfor\|endwhile\|endtry\|fi\|esac\|done\)\>\s*$'
      continue
    endif

    " 2. Code Symbols: }, ], ), }; 
    "    ] must be first in the class []] to be matched correctly
    if line =~ '^[+\-]\s*[\]})]\+;\?\s*$'
      continue
    endif

    " 3. HTML/XML closing tags
    if line =~ '^[+\-]\s*</[a-zA-Z0-9\-_]\+>\s*$'
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
  
  " PROMPT: STRICT SINGLE SENTENCE
  let l:system_prompt = "You are a git commit assistant. Your task is to look at the code changes and generate a SINGLE sentence describing what changed. Focus ONLY on the lines starting with '+' or '-'. Do not explain the context. Do not use quotes."
  
  let l:payload = {
  \ 'model': g:llm_model,
  \ 'prompt': l:system_prompt . "\n\n" . l:diff_content,
  \ 'stream': v:false,
  \ 'options': {'temperature': 0.1} 
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
      " Clean up any accidental newlines or leading bullets
      let l:msg = substitute(l:msg, '^[\r\n\t -]*', '', '')
      let l:msg = substitute(l:msg, '[\r\n]*$', '', '')
      call append(0, l:msg)
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
  
  " Test 1: Context Removal
  " In a git diff, context lines start with a space. They should be removed.
  let l:input = [' def context_line', '+def new_line', '-def old_line', ' end']
  let l:expected = ['+def new_line', '-def old_line']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected 
    call add(l:errors, "[Context] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif

  " Test 2: Structural Noise (Ruby)
  let l:input = ['+def hello', '+  puts "hi"', '+end', '+ end']
  let l:expected = ['+def hello', '+  puts "hi"']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected 
    call add(l:errors, "[Ruby] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif

  " Test 3: Structural Noise (JS/Brackets)
  let l:input = ['+function x() {', '+  return 1;', '+}', '+};']
  let l:expected = ['+function x() {', '+  return 1;']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected 
    call add(l:errors, "[JS] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif

  " Test 4: HTML Noise
  let l:input = ['+<div>', '+  Hello', '+</div>', '+   </p>']
  let l:expected = ['+<div>', '+  Hello']
  let l:actual = s:FilterLines(l:input)
  if l:actual != l:expected 
    call add(l:errors, "[HTML] Expected " . string(l:expected) . " but got " . string(l:actual))
  endif

  if len(l:errors) > 0
    throw join(l:errors, " | ")
  endif
endfunction
