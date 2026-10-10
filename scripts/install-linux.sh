#!/usr/bin/env bash
# Install the tools this Neovim config needs on Linux (Debian/Ubuntu, Fedora, Arch).
# Safe to re-run. Does NOT install the .NET SDK or touch ~/.config/nvim.
set -euo pipefail

SUDO=""
[ "$(id -u)" -ne 0 ] && SUDO="sudo"

# --- system packages -------------------------------------------------------
# build tools: treesitter parsers are compiled locally
# node/npm: Mason LSP servers, tree-sitter-cli, markdown-preview build
# ripgrep/fd: Telescope live_grep / find_files
# python3-venv/pip: Mason installs pip-based servers (autotools-language-server)
#   into venvs; Debian/Ubuntu split ensurepip out of the base python3 package
# xclip/wl-clipboard: system clipboard (unnamedplus)
if command -v apt-get >/dev/null; then
  $SUDO apt-get update -qq
  $SUDO apt-get install -y curl git unzip tar gcc g++ make nodejs npm python3 python3-venv python3-pip ripgrep fd-find xclip wl-clipboard
elif command -v dnf >/dev/null; then
  $SUDO dnf install -y curl git unzip tar gcc gcc-c++ make nodejs npm python3 python3-pip ripgrep fd-find xclip wl-clipboard
elif command -v pacman >/dev/null; then
  $SUDO pacman -Sy --needed --noconfirm curl git unzip tar gcc make nodejs npm python python-pip ripgrep fd xclip wl-clipboard
else
  echo "Unsupported package manager: install curl git unzip gcc make nodejs npm ripgrep manually." >&2
  exit 1
fi

# --- Neovim (config needs >= 0.12; distro packages are usually older) ------
need_nvim=1
if command -v nvim >/dev/null; then
  ver=$(nvim --version | head -1 | sed -E 's/^NVIM v([0-9]+)\.([0-9]+).*/\1 \2/')
  set -- $ver
  if [ "$1" -gt 0 ] || [ "$2" -ge 12 ]; then need_nvim=0; fi
fi

if [ "$need_nvim" -eq 1 ]; then
  case "$(uname -m)" in
    x86_64) asset=nvim-linux-x86_64 ;;
    aarch64 | arm64) asset=nvim-linux-arm64 ;;
    *) echo "Unsupported arch: $(uname -m)" >&2; exit 1 ;;
  esac
  tmp=$(mktemp -d)
  curl -fsSL "https://github.com/neovim/neovim/releases/latest/download/${asset}.tar.gz" -o "$tmp/nvim.tar.gz"
  $SUDO tar -xzf "$tmp/nvim.tar.gz" -C /opt
  $SUDO ln -sf "/opt/${asset}/bin/nvim" /usr/local/bin/nvim
  rm -r "$tmp"
fi

# --- npm global tools ------------------------------------------------------
# tree-sitter-cli: required by nvim-treesitter (main branch) to build parsers
# yarn: markdown-preview.nvim's build step (`cd app && yarn install`)
$SUDO npm install -g tree-sitter-cli yarn

echo
nvim --version | head -1
tree-sitter --version
echo "Done. Start nvim once and let lazy.nvim / Mason finish installing."
echo "Not installed: .NET SDK (needed for roslyn/netcoredbg)."
