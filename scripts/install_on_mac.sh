#!/bin/zsh
# Install script for macOS (Homebrew)
# Adapted from Ubuntu dotfiles install script

## Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

## Functions
debug() {
    echo -e "[${CYAN}DEBUG${NC}] ${CYAN}$@${NC}"
}
success() {
    echo -e "[${GREEN}SUCCESS${NC}] ${GREEN}$@${NC}"
}
error() {
    echo -e "[${RED}ERROR${NC}] ${RED}$@${NC}"
}

append_to_file() {
    grep -qF "$1" "$2" || echo "$1" >> "$2"
}

add_to_path() {
    debug "Adding $1 to PATH"
    if echo "$PATH" | grep -q "$1"; then
        success "Already in PATH"
    else
        export PATH="$PATH:$1"
        append_to_file "export PATH=\"\$PATH:$1\"" "$HOME/.zshrc"
    fi
}

is_installed() {
    command -v "$1" &> /dev/null
}

brew_install() {
    debug "Installing $@ via brew..."
    brew install "$@"
    [[ $? -eq 0 ]] && success "Successfully installed $@" || error "Failed to install $@"
}

brew_cask_install() {
    debug "Installing $@ via brew cask..."
    brew install --cask "$@"
    [[ $? -eq 0 ]] && success "Successfully installed $@" || error "Failed to install $@"
}

## Variables
LOCAL_BIN="$HOME/.local/bin"
TEMP="/tmp"

## MAIN ##

# Ensure brew is available
if ! is_installed brew; then
    error "Homebrew is not installed. Please install it first: https://brew.sh"
    exit 1
fi

# Update brew
debug "Updating Homebrew..."
brew update

# Create local bin directory
[[ ! -d $LOCAL_BIN ]] && mkdir -p $LOCAL_BIN

## Essentials
debug "Installing essential CLI tools..."
brew_install git vim tmux curl wget

## zsh (already default on macOS, but ensure it's up to date)
if brew list zsh &>/dev/null; then
    success "zsh (brew) already installed"
else
    brew_install zsh
fi

## oh-my-zsh
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    debug "Installing oh-my-zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    [[ $? -eq 0 ]] && success "oh-my-zsh installed" || error "Failed to install oh-my-zsh"
else
    success "oh-my-zsh already installed"
fi

## asdf (version manager)
if ! is_installed asdf; then
    brew_install asdf
    # Hook asdf into zsh
    append_to_file '. "$(brew --prefix asdf)/libexec/asdf.sh"' "$HOME/.zshrc"
    success "asdf installed — restart your terminal or run: source ~/.zshrc"
else
    success "asdf already installed"
fi

## fzf (fuzzy finder)
if ! is_installed fzf; then
    brew_install fzf
    # Install key bindings and fuzzy completion (Ctrl-R history search, Ctrl-T file search, etc.)
    "$(brew --prefix)/opt/fzf/install" --all --no-update-rc
    success "fzf installed with key bindings"
else
    success "fzf already installed"
fi

## Nerd Fonts
# Installing a curated selection — add/remove fonts to taste
NERD_FONTS=(
    font-jetbrains-mono-nerd-font   # great for coding
    font-meslo-lg-nerd-font         # default for Powerlevel10k
    font-fira-code-nerd-font        # popular with ligatures
    font-hack-nerd-font             # clean and minimal
)
debug "Installing Nerd Fonts..."
brew tap homebrew/cask-fonts 2>/dev/null || true   # tap may already exist
for font in "${NERD_FONTS[@]}"; do
    if brew list --cask "$font" &>/dev/null; then
        success "$font already installed"
    else
        brew_cask_install "$font"
    fi
done

## Tmux Plugin Manager (TPM)
TPM_DIR="$HOME/.tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
    debug "Installing Tmux Plugin Manager (TPM)..."
    git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
    [[ $? -eq 0 ]] && success "TPM installed at $TPM_DIR" || error "Failed to install TPM"
    echo ""
    debug "To finish TPM setup, ensure ~/.tmux.conf contains:"
    echo "    run '~/.tmux/plugins/tpm/tpm'"
    echo "  Then inside a live tmux session press: prefix + I   (capital i) to install plugins"
else
    success "TPM already installed"
fi

## .NET SDK
if ! is_installed dotnet; then
    brew_cask_install dotnet-sdk
else
    success "dotnet already installed"
fi

## Docker
if ! is_installed docker; then
    brew_cask_install docker
    success "Docker Desktop installed — open it from Applications to complete setup"
else
    success "Docker is already installed"
fi

## kubectl
if ! is_installed kubectl; then
    brew_install kubectl

    # Download kubelogin (oidc plugin)
    if [[ ! -f $LOCAL_BIN/kubelogin ]]; then
        debug "Installing kubelogin..."
        brew_install int128/kubelogin/kubelogin
    fi
else
    success "kubectl is already installed"
fi

## kubectx
if ! is_installed kubectx; then
    brew_install kubectx
else
    success "kubectx is already installed"
fi

## Google Chrome
if [[ ! -d "/Applications/Google Chrome.app" ]]; then
    brew_cask_install google-chrome
else
    success "Google Chrome already installed"
fi

## ngrok
if ! is_installed ngrok; then
    brew install ngrok/ngrok/ngrok
else
    success "ngrok already installed"
fi

## Neovim
if ! is_installed nvim; then
    brew_install neovim
else
    success "Neovim already installed"
fi

## 1Password
if [[ ! -d "/Applications/1Password.app" ]]; then
    brew_cask_install 1password
    brew_install 1password-cli
else
    success "1Password already installed"
fi

## Postman
if [[ ! -d "/Applications/Postman.app" ]]; then
    brew_cask_install postman
else
    success "Postman already installed"
fi

## Obsidian
if [[ ! -d "/Applications/Obsidian.app" ]]; then
    brew_cask_install obsidian
else
    success "Obsidian already installed"
fi

## Visual Studio Code
if ! is_installed code; then
    brew_cask_install visual-studio-code
else
    success "Visual Studio Code already installed"
fi

## Slack
if [[ ! -d "/Applications/Slack.app" ]]; then
    brew_cask_install slack
else
    success "Slack already installed"
fi

## Cloudflare WARP
if ! is_installed warp-cli; then
    brew_cask_install cloudflare-warp
    success "Cloudflare WARP installed — run 'warp-cli register' to set it up"
else
    success "Cloudflare WARP already installed"
fi

echo ""
success "All done! Restart your terminal or run 'source ~/.zshrc' to apply all changes."