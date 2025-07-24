# 💤 LazyVim

To use this config on a new machine:

```bash
# Remove any existing config
rm -rf ~/.config/nvim

# Clone this repo into your config directory
git clone git@github.com:mohammed-shakir/lazyvim-config.git ~/.config/nvim

# Open Neovim — plugins will install automatically
nvim

# After it loads once, sync LazyVim and quit
nvim +Lazy sync +qa

