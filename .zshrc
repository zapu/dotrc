autoload colors; colors

### Tab completion

# Force a reload of completion system if nothing matched; this fixes installing
# a program and then trying to tab-complete its name
_force_rehash() {
    (( CURRENT == 1 )) && rehash
    return 1    # Because we didn't really complete anything
}

# Always use menu completion, and make the colors pretty!
zstyle ':completion:*' menu select yes
zstyle ':completion:*:default' list-colors ''

# Completers to use: rehash, general completion, then various magic stuff and
# spell-checking.  Only allow two errors when correcting
zstyle ':completion:*' completer _force_rehash _complete _ignored _match _correct _approximate _prefix
zstyle ':completion:*' max-errors 2

# When looking for matches, first try exact matches, then case-insensiive, then
# partial word completion
zstyle ':completion:*' matcher-list '' 'm:{a-z}={A-Z}' 'r:|[._-]=** r:|=**'

# Turn on caching, which helps with e.g. apt
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Show titles for completion types and group by type
zstyle ':completion:*:descriptions' format "$fg_bold[black]» %d$reset_color"
zstyle ':completion:*' group-name ''

# Ignore some common useless files
zstyle ':completion:*' ignored-patterns '*?.pyc' '__pycache__'
zstyle ':completion:*:*:rm:*:*' ignored-patterns

# Do not try to autocomplete in parent dirs, it's annoying
# on network attached volumes.
zstyle ':completion:*' accept-exact-dirs true

# Always do mid-word tab completion
setopt complete_in_word

autoload -Uz compinit
compinit

### History
setopt extended_history hist_no_store hist_ignore_dups hist_expire_dups_first hist_find_no_dups inc_append_history share_history hist_reduce_blanks hist_ignore_space
export HISTFILE=~/.zsh_history
export HISTSIZE=1000000
export SAVEHIST=1000000

### Some..  options
setopt autocd beep extendedglob nomatch rc_quotes
unsetopt notify

setopt AUTO_PUSHD

# Don't count common path separators as word characters
WORDCHARS=${WORDCHARS//[&.;\/]}

REPORTTIME=5

### Prompt

PROMPT_nm="%{%(!.$fg_bold[red].$fg_bold[green])%}%n@%m%{$reset_color%} "
PROMPT_path="%{$fg_bold[blue]%}%~%{$reset_color%}"
# Comment out if you don't want path shortening
PROMPT_path="%{$fg_bold[blue]%}%(4~|%-1~/…/%2~|%3~)%{$reset_color%}"
PROMPT=$PROMPT_nm$PROMPT_path"%(!.#. ») "

RPROMPT_code="%(?..\$? %{$fg_no_bold[red]%}%?%{$reset_color%}  )"
RPROMPT_jobs="%1(j.%%# %{$fg_no_bold[cyan]%}%j%{$reset_color%}  .)"
RPROMPT_time="%{$fg_bold[black]%}%*%{$reset_color%}"
RPROMPT=$RPROMPT_code$RPROMPT_jobs$RPROMPT_time

### Misc environment and alias stuff

if whence ack-grep &> /dev/null; then
    alias ack=ack-grep
fi

# Don't glob with find or wget
for command in find wget; \
    alias $command="noglob $command"

### ls

LSOPTS='-lAvF --si'  # long mode, show all, natural sort, type squiggles, friendly sizes
LLOPTS=''
case $(uname -s) in
    FreeBSD)
        LSOPTS="${LSOPTS} -G"
        ;;
    Linux)
        eval "$(dircolors -b)"
        LSOPTS="$LSOPTS --color=auto"
        LLOPTS="$LLOPTS --color=always"  # so | less is colored

        # Just loaded new ls colors via dircolors, so change completion colors
        # to match
        zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}
        ;;
esac
alias ls="ls $LSOPTS"
alias ll="ls $LLOPTS | less -R"

### screen (and tmux's screen-compatible title support)

function title {
    # param: title to use

    local prefix=''

    # If I'm in a screen, all the windows are probably on the same machine, so
    # I don't really need to title every single one with the machine name.
    # On the other hand, if I'm not logged in as me (but, e.g., root), I'd
    # certainly like to know that!
    if [[ $USER != 'zapu' && $USER != 'michal' ]]; then
        prefix="[$USER] "
    fi
    # Set screen window title
    if [[ $TERM == "screen"* ]]; then
        print -n "\ek$prefix$1\e\\"
    fi


    # Prefix the xterm title with the current machine name, but only if I'm not
    # on a local machine.  This is tricky, because screen won't reliably know
    # whether I'm using SSH right now!  So just assume I'm local iff I'm not
    # running over SSH *and* not using screen.  Local screens are fairly rare.
    prefix=$HOST
    if [[ $SSH_CONNECTION == '' && $TERM != "screen"* ]]; then
        prefix=''
    fi
    # If we're showing host and I'm not under my usual username, prepend it
    if [[ $prefix != '' ]]; then
        prefix="$USER@$prefix"
    fi
    # Wrap it in brackets
    if [[ $prefix != '' ]]; then
        prefix="[$prefix] "
    fi

    # Set xterm window title
    if [[ $TERM == "xterm"* || $TERM == "screen"* ]]; then
        print -n "\e]2;$prefix$1\a"
    fi
}

function precmd {
    # Shorten homedir back to '~'
    local shortpwd=${PWD/$HOME/\~}
    title "zsh $shortpwd"
}

function preexec {
    title $*
}


### Keybindings

bindkey -e

# General movement
# Taken from http://wiki.archlinux.org/index.php/Zsh and Ubuntu's inputrc
bindkey "\e[1~" beginning-of-line
bindkey "\e[4~" end-of-line
bindkey "\e[5~" beginning-of-history
bindkey "\e[6~" end-of-history
bindkey "\e[3~" delete-char
bindkey "\e[2~" quoted-insert
bindkey "\e[1;5C" forward-word
bindkey "\e[1;5D" backward-word
bindkey "\e[5C" forward-word
bindkey "\eOc" emacs-forward-word
bindkey "\e[5D" backward-word
bindkey "\eOd" emacs-backward-word
bindkey "\e\e[C" forward-word
bindkey "\e\e[D" backward-word
# for rxvt
bindkey "\e[8~" end-of-line
bindkey "\e[7~" beginning-of-line
# for non RH/Debian xterm, can't hurt for RH/Debian xterm
bindkey "\eOH" beginning-of-line
bindkey "\eOF" end-of-line
# for freebsd console
bindkey "\e[H" beginning-of-line
bindkey "\e[F" end-of-line

# Tab completion
bindkey '^i' complete-word              # tab to do menu
bindkey "\e[Z" reverse-menu-complete    # shift-tab to reverse menu

# Up/down arrow.
# I want shared history for ^R, but I don't want another shell's activity to
# mess with up/down.  This does that.
down-line-or-local-history() {
    zle set-local-history 1
    zle down-line-or-history
    zle set-local-history 0
}
zle -N down-line-or-local-history
up-line-or-local-history() {
    zle set-local-history 1
    zle up-line-or-history
    zle set-local-history 0
}
zle -N up-line-or-local-history

bindkey "\e[A" up-line-or-local-history
bindkey "\eOA" up-line-or-local-history
bindkey "\e[B" down-line-or-local-history
bindkey "\eOB" down-line-or-local-history

page-up-within-tmux() {
    if [[ $TMUX == '' ]]; then
        # no-op; default behavior isn't useful, and anyway you don't want to do
        # something TOO cool here since you won't be able to do it inside tmux.
        # TODO if there's any way to command the /emu/ to scroll up one page, i
        # would love to hear about it
    else
        tmux copy-mode -u
    fi
}
zle -N page-up-within-tmux

# page up
bindkey "${terminfo[kpp]}" page-up-within-tmux

# Aliases

for command in find wget; \
	alias $command="noglob $command"

alias rcp="rsync -a --stats --progress"
# For syncing to targets that do not support permissions.
alias rcp_nop="rsync -a --stats --progress --no-perms"

alias igrep="grep -i"
alias findhere="noglob find . -iname"

function grephere() {
    grep_args=("-inIEr" "--color=ALWAYS")
    if [[ $# -eq 1 ]]; then
        # Just the search string: search in all files, recursively, 
        # in current dir.
        grep $grep_args $1 .
    elif [[ $# -eq 2 ]]; then
        # filetype and search string, filetype comes first.
        grep $grep_args --include $1 $2
    elif [[ $# -eq 3 ]]; then
        # Filetype, search str and directory.
        grep $grep_args --include $1 $2 $3
    fi
}

# get line $1 from output (counting from 1)
# (useful if e.g. find returns more than one)
# and we want to supply it with backticks
function sedpq() {
    sed -n -e "$1{p;q}"
}

# get first line from output 
alias fst="sedpq 1"

alias comptonglx="pkill compton ; compton --backend glx"

alias sublime="subl"

# clipboard support - be able to cat to/from clipboard using xclip
# E.g. "git --no-pager diff | clip", "clip -o | less"
alias clip="xclip -selection clipboard"
# pbcopy/pbpaste are OSX commands
alias pbcopy="clip"
alias pbpaste="clip -o"

alias p="pwd"
alias bwd='pwd | sed -e "s:/:🥖:g"'

alias hex_to_bin='xxd -r -p -'

add_pwd_to_path() {
    export PATH=`pwd`:$PATH
    echo $PATH
}

cdd() {
    cd $(dirname $1)
}

alias tig-latest='tig refs --sort=committerdate'

# Change prompt so it's easier to copy commands and outputs to show to someone.
demo_mode() {
    export BAK_RPROMPT=$RPROMPT
    export BAK_PROMPT=$PROMPT

    export RPROMPT=""
    export PROMPT="%(!.#.») "

    echo 'Demo mode prompt - `exit_demo` to exit'

    export exit_demo() {
        if [[ $BAK_PROMPT != '' ]]; then
            export RPROMPT=$BAK_RPROMPT
            export PROMPT=$BAK_PROMPT

            unset BAK_RPROMPT
            unset BAK_PROMPT
            unset exit_demo
        fi
    }
}

### Machine-specific extras

if [[ -r $HOME/.zlocal ]]; then
    source $HOME/.zlocal
fi

# Finds virtualenv activate and runs it, but asking first
# I don't like auto switchers that alias cd or do other magic,
# so here is this.
activate_venv() {
	cmd=$(find . -wholename "./*/bin/activate" | fst)
	if [[ $cmd != '' ]]; then
		read "?Are you sure you want to run $cmd ?"
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]; then
			source $cmd
		fi
	else
		echo "virtualenv activate not found"		
	fi
}

# Convert human units to bytes
dehumanise() {
  for v in "${@:-$(</dev/stdin)}"
  do
    echo $v | awk \
      'BEGIN{IGNORECASE = 1}
       function printpower(n,b,p) {printf "%u\n", n*b^p; next}
       /[0-9]$/{print $1;next};
       /K(iB)?$/{printpower($1,  2, 10)};
       /M(iB)?$/{printpower($1,  2, 20)};
       /G(iB)?$/{printpower($1,  2, 30)};
       /T(iB)?$/{printpower($1,  2, 40)};
       /KB$/{    printpower($1, 10,  3)};
       /MB$/{    printpower($1, 10,  6)};
       /GB$/{    printpower($1, 10,  9)};
       /TB$/{    printpower($1, 10, 12)}'
  done
}

export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'
