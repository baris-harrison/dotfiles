#!/bin/bash
# macOS preferences. Run by install.sh; safe to re-run. MDM may override some.
set -euo pipefail

[[ "$(uname -s)" == "Darwin" ]] || exit 0

# Keyboard: fast repeat, no accent popup (vim/less friendly)
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15
defaults write NSGlobalDomain ApplePressAndHoldEnabled -bool false

# Finder: show extensions, hidden files, path bar
defaults write NSGlobalDomain AppleShowAllExtensions -bool true
defaults write com.apple.finder AppleShowAllFiles -bool true
defaults write com.apple.finder ShowPathbar -bool true

# No .DS_Store on network/USB volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Screenshots out of the Desktop
mkdir -p "$HOME/Pictures/Screenshots"
defaults write com.apple.screencapture location -string "$HOME/Pictures/Screenshots"

# Dock
defaults write com.apple.dock show-recents -bool false

killall Finder Dock 2>/dev/null || true
