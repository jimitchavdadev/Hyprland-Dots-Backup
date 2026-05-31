# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="agnosterzak"

plugins=( 
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
)

# Speed up compinit by shadowing it during Oh-My-Zsh initialization
compinit() { : }

source $ZSH/oh-my-zsh.sh

# Restore real compinit and run it with cache validation
unfunction compinit
autoload -Uz compinit
if [ -n "$(find "${ZSH_COMPDUMP:-$HOME/.zcompdump}" -mmin +1440 2>/dev/null)" ] || [ ! -f "${ZSH_COMPDUMP:-$HOME/.zcompdump}" ]; then
    compinit -i -d "${ZSH_COMPDUMP:-$HOME/.zcompdump}"
else
    compinit -C -d "${ZSH_COMPDUMP:-$HOME/.zcompdump}"
fi


# Display Pokemon-colorscripts
# Project page: https://gitlab.com/phoneybadger/pokemon-colorscripts#on-other-distros-and-macos
#pokemon-colorscripts --no-title -s -r #without fastfetch
#pokemon-colorscripts --no-title -s -r | fastfetch -c $HOME/.config/fastfetch/config-pokemon.jsonc --logo-type file-raw --logo-height 10 --logo-width 5 --logo -

# fastfetch. Will be disabled if above colorscript was chosen to install
#fastfetch -c $HOME/.config/fastfetch/config-compact.jsonc

# Set-up icons for files/directories in terminal using lsd
alias ls='lsd'
alias l='ls -l'
alias la='ls -a'
alias lla='ls -la'
alias lt='ls --tree'

# User custom aliases
alias n='nvim'
alias q='exit'
alias c='clear'
alias nd='npm run dev'
alias nlint='npm run lint'
alias nbuild='npm run build'
alias tt='ttyper'
alias open='xdg-open'

# Copy absolute path to Wayland clipboard
cpath() {
    local target="${1:-.}"
    if [ -e "$target" ]; then
        realpath "$target" | tr -d '\n' | wl-copy
        echo "Copied path: $(wl-paste)"
    else
        echo "Error: '$target' does not exist." >&2
        return 1
    fi
}