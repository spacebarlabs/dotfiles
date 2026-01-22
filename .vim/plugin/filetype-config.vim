" =============================================================================
" FILETYPE-SPECIFIC CONFIGURATION
" =============================================================================
if has("autocmd")
  " Makefiles
  au FileType make set noexpandtab

  " Markdown
  au BufNewFile,BufRead *.{md,markdown} setfiletype markdown
  au BufNewFile,BufRead *.{md,markdown} setlocal spell

  " Markdown fenced code block syntax highlighting
  let g:markdown_fenced_languages = [
    \ 'ruby',
    \ 'erb=eruby',
    \ 'javascript',
    \ 'js=javascript',
    \ 'json',
    \ 'css',
    \ 'sass',
    \ 'scss=sass',
    \ 'html',
    \ 'bash=sh',
    \ 'sh',
    \ 'sql',
    \ 'xml',
    \ 'python',
    \ 'ts=typescript',
    \ 'typescript',
    \ 'yaml',
    \ 'go',
    \ 'vim',
    \ 'diff'
  \ ]

  " Prevent Vim from hiding formatting characters (like * or _)
  let g:markdown_syntax_conceal = 0

  " Git commits
  au FileType gitcommit setlocal spell

  " Resize splits when window size changes
  au VimResized * exe "normal! \<c-w>="

  " Remember last location in file
  " (Checks if filetype is NOT git commit, then jumps to last known cursor position)
  au BufReadPost * if &filetype !~ '^git\c' && line("'\"") > 0 && line("'\"") <= line("$")
    \| exe "normal! g`\"" | endif
endif
