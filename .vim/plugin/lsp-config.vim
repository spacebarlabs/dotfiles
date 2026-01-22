" =============================================================================
" VIM-LSP CONFIGURATION
" =============================================================================
" vim-lsp Settings
if executable('standardrb')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'standardrb',
        \ 'cmd': ['standardrb', '--lsp'],
        \ 'allowlist': ['ruby'],
        \ })
endif

" Enable format on save for vim-lsp
function! s:on_lsp_buffer_enabled() abort
  setlocal omnifunc=lsp#complete
  if exists('+tagfunc') | setlocal tagfunc=lsp#tagfunc | endif
  augroup lsp_format_on_save
    autocmd! * <buffer>
    autocmd BufWritePre <buffer> LspDocumentFormatSync
  augroup END
endfunction

augroup lsp_install
  au!
  autocmd User lsp_buffer_enabled call s:on_lsp_buffer_enabled()
augroup END

let g:ruby_indent_assignment_style = 'variable'
let g:ruby_indent_hanging_elements = 0
