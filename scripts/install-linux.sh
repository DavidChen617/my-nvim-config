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
# gdb: C/C++ debugging (nvim-dap talks to `gdb -i dap`, needs gdb >= 14);
#   libc6-dbg gives glibc debug info offline (Fedora/Arch use debuginfod instead)
if command -v apt-get >/dev/null; then
  $SUDO apt-get update -qq
  $SUDO apt-get install -y curl git unzip tar gcc g++ make nodejs npm python3 python3-venv python3-pip ripgrep fd-find xclip wl-clipboard gdb libc6-dbg
elif command -v dnf >/dev/null; then
  $SUDO dnf install -y curl git unzip tar gcc gcc-c++ make nodejs npm python3 python3-pip ripgrep fd-find xclip wl-clipboard gdb
elif command -v pacman >/dev/null; then
  $SUDO pacman -Sy --needed --noconfirm curl git unzip tar gcc make nodejs npm python python-pip ripgrep fd xclip wl-clipboard gdb
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

# --- glibc source (step into printf/read/... while debugging C) -----------
# Unpacked where the nvim-dap gdb adapter looks for it (lua/plugins.lua).
# Debian/Ubuntu: glibc-source at the installed libc6's exact version — its
# tarball already has the distro patches applied, so lines match the binary.
# Elsewhere: the upstream release tarball (distro patches may shift lines).
# .pkg-version records what was fetched, so a libc6 update re-fetches.
glibc_ver=$(getconf GNU_LIBC_VERSION | awk '{print $2}')
glibc_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvim/glibc-src"
glibc_dest="$glibc_dir/glibc-$glibc_ver"
libc_pkg_ver=$(dpkg-query -W -f='${Version}' libc6 2>/dev/null || echo "upstream-$glibc_ver")
if [ "$(cat "$glibc_dest/.pkg-version" 2>/dev/null)" != "$libc_pkg_ver" ]; then
  [ -d "$glibc_dest" ] && rm -r "$glibc_dest"
  mkdir -p "$glibc_dir"
  tmp=$(mktemp -d)
  if (cd "$tmp" && apt-get download "glibc-source=$libc_pkg_ver") >/dev/null 2>&1; then
    dpkg-deb --fsys-tarfile "$tmp"/glibc-source_*.deb | tar -x -C "$tmp" ./usr/src/glibc
    tar -xJf "$tmp"/usr/src/glibc/glibc-*.tar.xz -C "$glibc_dir"
  else
    curl -fsSL "https://ftp.gnu.org/gnu/glibc/glibc-${glibc_ver}.tar.xz" | tar -xJ -C "$glibc_dir"
  fi
  echo "$libc_pkg_ver" > "$glibc_dest/.pkg-version"
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
