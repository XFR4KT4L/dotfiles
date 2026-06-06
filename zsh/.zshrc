# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
bindkey -e
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/trafalgar/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

# Prompt
PROMPT='%F{#cba6f7}ソウ%f %F{#89b4fa}→%f '

# Búsqueda en historial por prefijo con flechas
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search
