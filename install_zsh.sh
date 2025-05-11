#!/bin/bash

set -e

DOTFILES_DIR="$HOME/dotfiles"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "[INFO] Creating symlinks..."
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/.p10k.zsh" ] && ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

echo "[INFO] Installing Zsh..."
if command -v zsh >/dev/null 2>&1; then
    echo "[INFO] Zsh is already installed."
else
    if command -v apt &>/dev/null; then
        sudo apt update && sudo apt install -y zsh git curl
    elif command -v brew &>/dev/null; then
        brew install zsh git curl
    else
        echo "[ERROR] No supported package manager found (apt or brew). Install Zsh manually."
        exit 1
    fi
fi

ZSH_PATH="$(command -v zsh)"

if [ -z "$ZSH_PATH" ]; then
    echo "[ERROR] Zsh installation failed or not in PATH."
    exit 1
fi

echo "[INFO] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "[INFO] Oh My Zsh already installed."
fi

# Install Powerlevel10k, if not already installed
if [ ! -d "$ZSH_CUSTOM/themes/powerlevel10k" ]; then
    echo "[INFO] Installing Powerlevel10k..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
else
    echo "[INFO] Powerlevel10k already exists."
fi

# Install zsh-autosuggestions, if not already installed
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    echo "[INFO] Installing zsh-autosuggestions..."
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
else
    echo "[INFO] Autosuggestions already installed."
fi

# Install zsh-syntax-highlighting, if not already installed
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    echo "[INFO] Installing zsh-syntax-highlighting..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
else
    echo "[INFO] Syntax highlighting already installed."
fi

echo "[INFO] Setting Zsh as default shell..."

if grep -q "$ZSH_PATH" /etc/shells; then
    echo "[INFO] $ZSH_PATH is already in /etc/shells"
else
    echo "[INFO] Adding $ZSH_PATH to /etc/shells"
    echo "$ZSH_PATH" | sudo tee -a /etc/shells
fi

# Try to change shell using chsh
if chsh -s "$ZSH_PATH" >/dev/null 2>&1; then
    echo "[INFO] Default shell changed with chsh"
else
    echo "[WARN] chsh failed (PAM or permission issue), trying to update /etc/passwd manually..."
    USERNAME=$(whoami)
    sudo sed -i "s|^\($USERNAME:.*:\)[^:]*$|\1$ZSH_PATH|" /etc/passwd
    echo "[INFO] Default shell changed manually for user $USERNAME"
fi

echo "[INFO] Setup complete. Launching Zsh..."
exec "$ZSH_PATH"


