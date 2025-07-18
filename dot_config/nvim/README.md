**AstroNvim Config Fork**

This repository contains my customized AstroNvim setup. 

---

## 1. Sync with Upstream

Pull in the latest changes from the official AstroNvim template:

```bash
# (Only if you haven't already) Add the official AstroNvim template as upstream
git remote add upstream https://github.com/AstroNvim/template.git

# Fetch and rebase your custom commits on top of the latest template
git pull --rebase upstream main -X theirs

# Push the rebased history to your fork
git push origin main --force-with-lease
```

---

## 2. Install on a New Machine

Clone and bootstrap AstroNvim:

```bash
# Clone into the standard Neovim config directory
git clone git@github.com:mohammed-shakir/astronvim_config.git ~/.config/nvim

# Install plugins and apply your config headlessly
nvim --headless -c 'quitall'
```
