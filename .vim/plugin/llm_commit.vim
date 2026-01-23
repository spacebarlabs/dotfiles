" ==============================================================================
"  LLM Git Commit Generator (Async + Refinement + Long/Short Display)
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

  " Strip Null Bytes
  let l:txt = substitute(l:txt, '\%x00', '', 'g')

  " Strip Markdown
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

        " CASE A: DRAFT STAGE
        if a:ctx.stage == 'draft'
          " If short enough, display immediately (only short version)
          if len(l:msg) <= 50 && l:msg !~ '\n'
             call s:DisplayOption(a:ctx.type, l:msg, "")
             return
          else
             " Too long? Send to Refinement Loop
             " Pass the current msg as 'original' so we can display it later
             call s:LaunchRefinement(a:ctx.type, l:msg)
             return
          endif
        endif

        " CASE B: REFINEMENT STAGE
        " We now have the Summary (l:msg) and the Original (a:ctx.original)
        if a:ctx.stage == 'refine'
          " Failsafe: If summary is still multiline, take first line
          let l:summary_lines = split(l:msg, "\n")
          let l:short_ver = (len(l:summary_lines) > 0) ? l:summary_lines[0] : l:msg

          call s:DisplayOption(a:ctx.type, l:short_ver, a:ctx.original)
        endif

      endif
    catch
    endtry
  endif
endfunction

" --- 3. Display Formatter ---
function! s:DisplayOption(type, short, long)
  let l:block = []

  call add(l:block, "### Option (" . a:type . ")")
  call add(l:block, "#")
  call add(l:block, "# " . a:short)

  " Only add long version if it exists
  if len(a:long) > 0
    call add(l:block, "#")
    call add(l:block, "# " . a:long)
  endif

  call add(l:block, "") " Spacer

  " Insert at the very top (pushing previous options down)
  call append(0, l:block)
  normal! gg
endfunction

" --- 4. Engine-Specific Callbacks ---
function! s:OnExitNvim(job_id, code, event)
  if has_key(s:jobs, a:job_id)
    call s:FinishJob(s:jobs[a:job_id])
    call remove(s:jobs, a:job_id)
  endif
endfunction

function! s:OnExitVim(ctx, job, status)
  call s:FinishJob(a:ctx)
endfunction

" --- 5. Async Launchers ---

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
    let l:prompt = l:prompt . " Do NOT use markdown. Do NOT list functions. Just describe the change."
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

  let l:ctx = { 'out_file': l:out_file, 'in_file': l:in_file, 'type': a:label, 'stage': 'draft' }
  call s:StartJob(l:cmd, l:ctx)
endfunction

" B. Refinement Worker (Summarizer)
function! s:LaunchRefinement(label, verbose_text)
  let l:prompt = "Rewrite this git commit message to be under 50 characters. Imperative mood. No trailing period. Text: "

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

  " Pass original text in ctx.original
  let l:ctx = {
  \ 'out_file': l:out_file,
  \ 'in_file': l:in_file,
  \ 'type': a:label,
  \ 'stage': 'refine',
  \ 'original': a:verbose_text
  \ }
  call s:StartJob(l:cmd, l:ctx)
endfunction

" --- 6. Strategy Filter ---
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

function! GenerateCommitMsg()
  let l:ping = system('curl -s -o /dev/null -w "%{http_code}" --connect-timeout 0.1 ' . g:llm_host)
  if l:ping != "200"
    echo "Ollama is offline. Skipping."
    return
  endif

  echo "Thinking (3 options)..."
  let l:lines = getline(1, 2000)

  call s:LaunchWorker('comments', 'Intent/Comments', l:lines)
  call s:LaunchWorker('high_level', 'High-Level', l:lines)
  call s:LaunchWorker('full', 'Standard', l:lines)
endfunction

augroup LLMCommit
  autocmd!
  autocmd FileType gitcommit if getline(1) == '' | call GenerateCommitMsg() | endif
augroup END

command! GitCommit call GenerateCommitMsg()
