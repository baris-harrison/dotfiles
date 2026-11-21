# History: big, shared across sessions, no dupes, ignore space-prefixed
# commands (prefix a command with a space to keep a token out of history).
HISTFILE="$XDG_STATE_HOME/zsh/history"
[[ -d ${HISTFILE:h} ]] || mkdir -p "${HISTFILE:h}"
HISTSIZE=100000
SAVEHIST=100000
setopt EXTENDED_HISTORY SHARE_HISTORY HIST_IGNORE_ALL_DUPS \
       HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY

setopt AUTO_CD AUTO_PUSHD PUSHD_IGNORE_DUPS INTERACTIVE_COMMENTS \
       NO_BEEP EXTENDED_GLOB

bindkey -e   # emacs keys; change to -v for vi mode
