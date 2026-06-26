" Must be first. Resets vim to default settings, fixing vi bugs.
set nocompatible

if (has("termguicolors"))
  set termguicolors
endif

" Directories for swp files
set backupdir=~/.vim/backup
set directory=~/.vim/backup
" Create directories if they don't exist
if !isdirectory(&backupdir) | call mkdir(&backupdir, "p") | endif
if !isdirectory(&directory) | call mkdir(&directory, "p") | endif

" =============================================================================
" PLUGINS
" =============================================================================
"
" Plugins are managed as git submodules in .vim/pack/plugins/start/
" They are automatically loaded by Vim's native package management

" Enable filetype detection, plugins, and indenting
filetype plugin indent on

" =============================================================================
" EDITOR SETTINGS
" =============================================================================
set number
set ruler
set lazyredraw        " Don't update screen during macros
set showcmd           " Show incomplete commands

" Whitespace & Indentation
set smartindent
set nowrap                      " Don't wrap lines by default
set tabstop=2 shiftwidth=2      " Tab is two spaces
set expandtab                   " Use spaces, not tabs
set backspace=indent,eol,start  " Backspace through everything

" Wrapping (visual only)
set showbreak=...
set wrap linebreak nolist

" Searching
set hlsearch
set incsearch
set ignorecase
set smartcase

" Buffers & Status
set hidden
set laststatus=2
set statusline=%<%f\ (%{&ft})\ %-4(%m%)%=%-19(%3l,%02c%03V%)

" Wildmenu (command line completion)
set wildmode=list:longest
set wildmenu

" Theme
syntax enable
try
  colorscheme dracula
catch
  colorscheme default
endtry

" Fix truecolor bug for vim if needed
if has('termguicolors')
  let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
  let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

" =============================================================================
" MAPPINGS
" =============================================================================
let mapleader=","
let maplocalleader = ","

" GitGutter
set signcolumn=yes

" =============================================================================
" CONFIGURATION & AUTOCOMMANDS
" =============================================================================

" CtrlP
let g:ctrlp_user_command = ['.git/', 'git --git-dir=%s/.git ls-files -oc --exclude-standard']

" Security
set exrc
set secure

set noerrorbells
set novisualbell

" ========
" Org-Mode
" ========

" === Dynamic Agenda Discovery ===
" 1. Initialize empty list
let g:org_agenda_files = []

" 2. Find all directories ending in .orgmode inside ~/git
"    (Change '~/git' if you move your code folder)
let s:org_repos = glob('~/git/*.orgmode', 0, 1)

" 3. Loop through repos and add only the active GTD files
for repo in s:org_repos
  for filename in ['inbox.org', 'projects.org', 'tickler.org']
    let s:path = repo . '/' . filename
    " Only add the file if it actually exists
    if filereadable(expand(s:path))
      call add(g:org_agenda_files, s:path)
    endif
  endfor
endfor

" Cleanup temporary variables to keep global scope clean
unlet s:org_repos
if exists('s:path')
  unlet s:path
endif

let g:org_todo_keywords = [['TODO', 'NEXT', 'WAITING', '|', 'DONE', 'CANCELLED']]
let g:org_heading_shade_leading_stars = 1
let g:org_log_done = 'time'
let g:org_log_repeat = 'time'

" wikilink: Window split on footer and sidebar detection can be disabled by writing this
let wikilinkAutosplit="off"

if has('nvim-0.11')
packadd codecompanion.nvim

lua << EOF
require("codecompanion").setup({
  log_level = "DEBUG",
  strategies = {
    chat = { adapter = "ollama" },
    inline = { adapter = "ollama" },
  },
  adapters = {
    ollama = function()
      return require("codecompanion.adapters").extend("ollama", {
        env = { url = "http://192.168.8.228:11434" },
        schema = {
          -- model = { default = "phi4-reasoning:latest" },
          model = { default = "qwen2.5-coder:1.5b" },
          temperature = { default = 0.0 },
        },
      })
    end,
  },
})

-- =============================================================================
-- Resilient Watchdog Spinner Controls
-- =============================================================================
local feedback_group = vim.api.nvim_create_augroup("CodeCompanionFeedback", { clear = true })
spinner_timer = nil  -- Kept global so emergency macros can target it
local spinner_frames = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local spinner_idx = 1
local ticks = 0

local function cleanup_spinner()
  if spinner_timer then
    spinner_timer:stop()
    spinner_timer:close()
    spinner_timer = nil
  end
  ticks = 0
end

vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionRequestStarted",
  group = feedback_group,
  callback = function()
    cleanup_spinner() -- Force kill any pre-existing loops before starting
    spinner_timer = (vim.uv or vim.loop).new_timer()
    spinner_timer:start(0, 100, vim.schedule_wrap(function()
      ticks = ticks + 1
      -- SAFETY WATCHDOG: If it loops for more than 40 seconds (400 ticks), self-terminate
      if ticks > 3000 then
        cleanup_spinner()
        vim.api.nvim_echo({ { "⚠️  Ollama timeout or request dropped.", "ErrorMsg" } }, false, {})
        return
      end

      spinner_idx = (spinner_idx % #spinner_frames) + 1
      vim.api.nvim_echo({
        { "⚙️  Ollama is computing... ", "WarningMsg" },
        { spinner_frames[spinner_idx], "Identifier" },
        -- { " (phi4-reasoning:latest)", "Comment" }
        { " (qwen2.5-coder:1.5b)", "Comment" }
      }, false, {})
    end))
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionRequestFinished",
  group = feedback_group,
  callback = function()
    cleanup_spinner()
    vim.api.nvim_echo({ { "✅ AI Response Delivered!", "String" } }, false, {})
  end,
})

-- =============================================================================
-- Custom Code Transformer Core with Absolute Line Mapping
-- =============================================================================
vim.api.nvim_create_user_command('HerbFixContext', function()
  cleanup_spinner() -- Reset screen state cleanly on invocation

  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local start_line = math.max(1, current_line - 5)
  local end_line = current_line + 10

  local qf_list = vim.fn.getqflist()
  local qf_info = vim.fn.getqflist({ idx = 0 })
  local current_idx = qf_info.idx

  local error_text = ""
  if qf_list and qf_list[current_idx] then
    error_text = qf_list[current_idx].text
  end

  -- Hardened prompt syntax: Remind the model to stay inside CodeCompanion's markdown parser block
  local prompt = string.format(
    "This selection shows absolute lines %d-%d. Fix the HTML/ERB syntax mismatch, unclosed/wrong tag, or typo causing this Herb error: %s. " ..
    "Return the fix wrapped immediately in a standard markdown code block so the diff system can parse it.",
    start_line, end_line, error_text
  )

  -- Highlight context lines visually
  vim.cmd(string.format("normal! %dGV%dG", start_line, end_line))

  -- Pass selection straight into CodeCompanion
  local cmd = string.format(":CodeCompanion %s<CR>", prompt)
  local keys = vim.api.nvim_replace_termcodes(cmd, true, false, true)
  vim.api.nvim_feedkeys(keys, 'n', false)
end, {})

vim.keymap.set('n', '<leader>cf', ':HerbFixContext<CR>', { desc = 'Fix HTML error with CodeCompanion' })
EOF
endif
