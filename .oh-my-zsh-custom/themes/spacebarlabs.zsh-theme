#vi: ft=zsh

mise_prompt_info() {
  # Check if mise exists
  if ! command -v mise &> /dev/null; then return; fi

  local tools
  # 1. Run mise ls
  # 2. Awk Filters: Track ruby separately and count the rest
  tools=$(mise ls --no-header 2>/dev/null | awk '
    $3 != "" && \
    $3 !~ /config\.toml$/ && \
    $3 != "~/.tool-versions" {
      if ($1 == "ruby") {
        ruby_ver = "ruby:" $2
      } else {
        other_count++
      }
    }
    END {
      if (ruby_ver && other_count) {
        print ruby_ver " (mise+" other_count ")"
      } else if (ruby_ver) {
        print ruby_ver
      } else if (other_count) {
        print "(mise+" other_count ")"
      }
    }
  ')

  # Only print if tools were found
  if [ -n "$tools" ]; then
    echo "%{$fg[red]%}‹$tools›%{$reset_color%}"
  fi
}

yadm_prompt_info() {
  # Only show yadm branch when in home directory
  if [[ "$PWD" != "$HOME" ]]; then
    return
  fi

  # Check if yadm repo exists
  # We use git directly with yadm's repo path instead of the yadm command
  # to avoid dependency on yadm being installed (repo may exist without yadm)
  local yadm_repo="$HOME/.local/share/yadm/repo.git"
  if [[ ! -d "$yadm_repo" ]]; then
    return
  fi

  # Get the current branch from yadm repository
  local branch
  branch=$(git --git-dir="$yadm_repo" --work-tree="$HOME" symbolic-ref --short HEAD 2>/dev/null)

  # Only print if branch was found
  if [[ -n "$branch" ]]; then
    echo "%{$fg[cyan]%}‹yadm:$branch›"
  fi
}

local current_time_iso8601='$(date +"%Y-%m-%dT%H:%M:%S")'

local return_code="%(?..%{$fg[red]%}%? ↵%{$reset_color%})"

local user_host='%{$terminfo[bold]$fg[green]%}%n@%m%{$reset_color%}'
local current_dir='%{$terminfo[bold]$fg[blue]%} %~%{$reset_color%}'
local git_branch='$(git_prompt_info)%{$reset_color%}'
local yadm_branch='$(yadm_prompt_info)%{$reset_color%}'

PROMPT="${user_host} ${current_dir} \$(mise_prompt_info) ${git_branch} ${yadm_branch} \$BUNDLE_GEMFILE  (${current_time_iso8601})
%B$%b "

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg[yellow]%}‹"
ZSH_THEME_GIT_PROMPT_SUFFIX="› %{$reset_color%}"
