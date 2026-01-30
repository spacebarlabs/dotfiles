" 1. Clear existing links (removes the blue box)
highlight clear org_todo_keyword_TODO
highlight clear org_todo_keyword_DONE
highlight clear org_todo_keyword_NEXT
highlight clear org_todo_keyword_WAITING

" 2. Apply Dracula Colors explicitly
" TODO = Pink (#ff79c6)
highlight org_todo_keyword_TODO guifg=#ff79c6 ctermfg=212 guibg=NONE ctermbg=NONE gui=bold cterm=bold

" DONE = Green (#50fa7b)
highlight org_todo_keyword_DONE guifg=#50fa7b ctermfg=120 guibg=NONE ctermbg=NONE gui=bold cterm=bold

" NEXT = Orange (#ffb86c)
highlight org_todo_keyword_NEXT guifg=#ffb86c ctermfg=215 guibg=NONE ctermbg=NONE gui=bold cterm=bold

" WAITING = Yellow (#f1fa8c) / Italic
highlight org_todo_keyword_WAITING guifg=#f1fa8c ctermfg=228 guibg=NONE ctermbg=NONE gui=italic cterm=italic

" 3. General Elements
" Dates (Cyan Underline)
highlight orgDate guifg=#8be9fd ctermfg=117 gui=underline cterm=underline

" Headings (Purple Hierarchy)
highlight orgLevel1 guifg=#bd93f9 ctermfg=141 gui=bold cterm=bold
highlight orgLevel2 guifg=#ff79c6 ctermfg=212 gui=bold cterm=bold
