#!/bin/bash

DOTFILES_DIR="$HOME/dotfiles"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

echo "[INFO] Creating symlinks..."
ln -sf "$DOTFILES_DIR/.zshrc" "$HOME/.zshrc"
[ -f "$DOTFILES_DIR/.p10k.zsh" ] && ln -sf "$DOTFILES_DIR/.p10k.zsh" "$HOME/.p10k.zsh"

echo "[INFO] Installing Zsh..."
if command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y zsh git curl
elif command -v brew &>/dev/null; then
    brew install zsh git curl
else
    echo "[ERROR] No supported package manager found (apt or brew). Install Zsh manually."
    exit 1
fi

echo "[INFO] Installing Oh My Zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
    echo "[INFO] Oh My Zsh already installed."
fi

echo "[INFO] Installing Powerlevel10k..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"

echo "[INFO] Installing zsh-autosuggestions..."
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

echo "[INFO] Installing zsh-syntax-highlighting..."
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "[INFO] Setting Zsh as default shell..."
chsh -s "$(which zsh)"

echo "[INFO] Setup complete. Launching Zsh..."
exec zsh

