" ==============================================================================
"  LLM Git Commit Generator (Async + Refinement Loop)
" ==============================================================================

if !exists('g:llm_host')
  let g:llm_host = 'http://localhost:11434'
endif

if !exists('g:llm_model')
  let g:llm_model = 'qwen2.5-coder:1.5b'
endif

" Registry for Neovim jobs
let s:jobs = {}

" --- 1. Output Cleaner ---
function! s:CleanMsg(msg)
  let l:txt = a:msg
  
  " Strip Null Bytes (NUL) - Critical for Vim buffers
  let l:txt = substitute(l:txt, '\%x00', '', 'g')
  
  " Strip Markdown wrappers
  let l:txt = substitute(l:txt, '^```[a-z]*\s*', '', '')
  let l:txt = substitute(l:txt, '\s*```$', '', '')
  let l:txt = substitute(l:txt, '^["`'']', '', '')
  let l:txt = substitute(l:txt, '["`'']$', '', '')
  
  " JSON Fallback
  if l:txt =~ '^\s*{'
    try
      let l:obj = json_decode(l:txt)
      let l:txt = get(l:obj, 'message', get(l:obj, 'commit', l:txt))
    catch
    endtry
  endif
  
  " Strip Headers/Lists
  let l:txt = substitute(l:txt, '^#\+\s*', '', '')
  let l:txt = substitute(l:txt, '^\s*-\s*', '', '')
  let l:txt = substitute(l:txt, '\.$', '', '')
  
  return trim(l:txt)
endfunction

" --- 2. Common Completion Handler ---
function! s:FinishJob(ctx)
  " Cleanup temp files
  if filereadable(a:ctx.in_file) | call delete(a:ctx.in_file) | endif

  if filereadable(a:ctx.out_file)
    let l:raw = join(readfile(a:ctx.out_file), "\n")
    call delete(a:ctx.out_file)
    
    try
      let l:json = json_decode(l:raw)
      if has_key(l:json, 'response')
        let l:msg = s:CleanMsg(l:json.response)
        
        if len(l:msg) < 5 | return | endif

        " --- REFINEMENT LOGIC ---
        " If this is a DRAFT and it's too long (>72 chars) or multiline...
        " ...feed it back into the LLM to summarize it.
        if a:ctx.stage == 'draft'
          if len(l:msg) > 72 || l:msg =~ '\n'
             " Trigger Refinement Loop
             call s:LaunchRefinement(a:ctx.type, l:msg)
             return
          endif
        endif

        " If we are here, either it was short enough, or it's the Refined version.
        " Final Failsafe: Take only the first line to guarantee "Safe Space" compliance.
        let l:lines = split(l:msg, "\n")
        if len(l:lines) > 0
          let l:final_header = l:lines[0]
          
          let l:header = "### Option (" . a:ctx.type . "): " . l:final_header
          call append(0, "")
          call append(0, l:header)
          normal! gg
        endif
      endif
    catch
    endtry
  endif
endfunction

" --- 3. Engine-Specific Callbacks ---
function! s:OnExitNvim(job_id, code, event)
  if has_key(s:jobs, a:job_id)
    call s:FinishJob(s:jobs[a:job_id])
    call remove(s:jobs, a:job_id)
  endif
endfunction

function! s:OnExitVim(ctx, job, status)
  call s:FinishJob(a:ctx)
endfunction

" --- 4. Strategy Filter ---
function! s:GetFilteredDiff(lines, strategy)
  let l:result = []
  for line in a:lines
    if line =~ '^ ' || line =~ '^[+\- ]\?\s*$' | continue | endif
    if line =~ '^#' | continue | endif

    if a:strategy == 'full'
      if line =~ '^[+\-]\s*\<\(end\|endif\|done\|fi\)\>\s*$' | continue | endif
      if line =~ '^[+\-]\s*[\]})]\+;\?\s*$' | continue | endif
      call add(l:result, line)
    elseif a:strategy == 'high_level'
      if line =~ 'class\|def\|func\|struct\|interface\|module'
        call add(l:result, line)
      endif
    elseif a:strategy == 'comments'
      if line =~ '^\s*[+\-]\s*\(//\|#\|"\|\*\|/\*\)'
        call add(l:result, line)
      endif
    endif
  endfor
  return join(l:result, "\n")
endfunction

" --- 5. Async Launchers ---

" Helper to actually start the job
function! s:StartJob(cmd, ctx)
  if has('nvim')
    let l:job_id = jobstart(a:cmd, { 'on_exit': function('s:OnExitNvim') })
    let s:jobs[l:job_id] = a:ctx
  else
    call job_start(a:cmd, { 'exit_cb': function('s:OnExitVim', [a:ctx]) })
  endif
endfunction

" A. Initial Worker (Draft)
function! s:LaunchWorker(strategy, label, buffer_lines)
  let l:diff = s:GetFilteredDiff(a:buffer_lines, a:strategy)
  if len(l:diff) < 5 | return | endif

  let l:prompt = "You are a git commit assistant. Analyze the code changes and generate a SINGLE sentence in English describing what changed. Use the IMPERATIVE mood. Use ACTIVE voice. Omit the trailing period. Output only the raw English text."
  
  if a:strategy == 'full'
    let l:prompt = l:prompt . " Do NOT generate a summary. Do NOT use markdown. Do NOT explain the code. Just write the commit message."
  endif

  let l:payload = {
  \ 'model': g:llm_model,
  \ 'prompt': l:prompt . "\n\n" . l:diff,
  \ 'stream': v:false,
  \ 'options': {'temperature': 0.2}
  \ }
  
  let l:in_file = tempname()
  call writefile([json_encode(l:payload)], l:in_file)
  let l:out_file = tempname()
  let l:cmd = ['curl', '-s', '-X', 'POST', g:llm_host . '/api/generate', '-d', '@' . l:in_file, '-o', l:out_file]
  
  " Stage = 'draft'
  let l:ctx = { 'out_file': l:out_file, 'in_file': l:in_file, 'type': a:label, 'stage': 'draft' }
  call s:StartJob(l:cmd, l:ctx)
endfunction

" B. Refinement Worker (Summarizer)
function! s:LaunchRefinement(label, verbose_text)
  " The Refinement Prompt
  let l:prompt = "The following text describes a code change. Rewrite it as a SHORT, SINGLE-LINE git commit subject (max 50 chars). Imperative mood. No trailing period. Text: "

  let l:payload = {
  \ 'model': g:llm_model,
  \ 'prompt': l:prompt . "\n\n" . a:verbose_text,
  \ 'stream': v:false,
  \ 'options': {'temperature': 0.1}
  \ }
  
  let l:in_file = tempname()
  call writefile([json_encode(l:payload)], l:in_file)
  let l:out_file = tempname()
  let l:cmd = ['curl', '-s', '-X', 'POST', g:llm_host . '/api/generate', '-d', '@' . l:in_file, '-o', l:out_file]
  
  " Stage = 'refine' (prevents infinite loops)
  let l:ctx = { 'out_file': l:out_file, 'in_file': l:in_file, 'type': a:label, 'stage': 'refine' }
  call s:StartJob(l:cmd, l:ctx)
endfunction

function! GenerateCommitMsg()
  let l:ping = system('curl -s -o /dev/null -w "%{http_code}" --connect-timeout 0.1 ' . g:llm_host)
  if l:ping != "200"
    echo "Ollama is offline. Skipping."
    return
  endif

  echo "Thinking (3 options)..."
  let l:lines = getline(1, 2000)
  
  " 1. Intent/Comments
  call s:LaunchWorker('comments', 'Intent/Comments', l:lines)
  
  " 2. High Level
  call s:LaunchWorker('high_level', 'High-Level', l:lines)
  
  " 3. Standard
  call s:LaunchWorker('full', 'Standard', l:lines)
endfunction

augroup LLMCommit
  autocmd!
  autocmd FileType gitcommit if getline(1) == '' | call GenerateCommitMsg() | endif
augroup END

command! GitCommit call GenerateCommitMsg()
