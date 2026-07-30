#!/usr/bin/env bash
#===============================================================================
# modern_linux_tools.sh -- prebuilt "modern unix" single-binary tools.
#
# Installs (non-root, into ~/.local/bin): ripgrep(rg), fd, bat, delta, eza,
# procs, lazygit. Each picks up the LATEST GitHub release by default; pin a
# specific version by exporting <TOOL>_VERSION, e.g.:
#     RG_VERSION=14.1.1 ./modern_linux_tools.sh
#===============================================================================
set -euo pipefail
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/lib.sh"

sm_require curl tar unzip

# ripgrep -- BurntSushi/ripgrep, tag has NO leading v (e.g. 14.1.1)
sm_install_ripgrep() {
   local v; v="$(sm_nov "$(sm_resolve_version "${RG_VERSION:-}" BurntSushi/ripgrep)")"
   sm_banner ripgrep "$v"; sm_workdir ripgrep >/dev/null
   local d="ripgrep-${v}-x86_64-unknown-linux-musl"
   sm_fetch_extract "https://github.com/BurntSushi/ripgrep/releases/download/${v}/${d}.tar.gz"
   sm_install_bin "${d}/rg"
}

# fd -- sharkdp/fd, tag HAS leading v (e.g. v10.4.2)
sm_install_fd() {
   local tag v; tag="$(sm_resolve_version "${FD_VERSION:-}" sharkdp/fd)"; v="$(sm_nov "$tag")"
   sm_banner fd "$v"; sm_workdir fd >/dev/null
   local d="fd-v${v}-x86_64-unknown-linux-musl"
   sm_fetch_extract "https://github.com/sharkdp/fd/releases/download/v${v}/${d}.tar.gz"
   sm_install_bin "${d}/fd"
}

# bat -- sharkdp/bat, tag HAS leading v
sm_install_bat() {
   local v; v="$(sm_nov "$(sm_resolve_version "${BAT_VERSION:-}" sharkdp/bat)")"
   sm_banner bat "$v"; sm_workdir bat >/dev/null
   local d="bat-v${v}-x86_64-unknown-linux-musl"
   sm_fetch_extract "https://github.com/sharkdp/bat/releases/download/v${v}/${d}.tar.gz"
   sm_install_bin "${d}/bat"
}

# delta -- dandavison/delta, tag has NO leading v (e.g. 0.18.2)
sm_install_delta() {
   local v; v="$(sm_nov "$(sm_resolve_version "${DELTA_VERSION:-}" dandavison/delta)")"
   sm_banner delta "$v"; sm_workdir delta >/dev/null
   local d="delta-${v}-x86_64-unknown-linux-musl"
   sm_fetch_extract "https://github.com/dandavison/delta/releases/download/${v}/${d}.tar.gz"
   sm_install_bin "${d}/delta"
}

# eza -- eza-community/eza, asset name has NO version embedded
sm_install_eza() {
   local tag; tag="$(sm_resolve_version "${EZA_VERSION:-}" eza-community/eza)"
   sm_banner eza "$(sm_nov "$tag")"; sm_workdir eza >/dev/null
   sm_fetch_extract "https://github.com/eza-community/eza/releases/download/${tag}/eza_x86_64-unknown-linux-gnu.zip"
   sm_install_bin ./eza
}

# procs -- dalance/procs, tag HAS leading v; asset embeds version w/o v
sm_install_procs() {
   local v; v="$(sm_nov "$(sm_resolve_version "${PROCS_VERSION:-}" dalance/procs)")"
   sm_banner procs "$v"; sm_workdir procs >/dev/null
   sm_fetch_extract "https://github.com/dalance/procs/releases/download/v${v}/procs-v${v}-x86_64-linux.zip"
   sm_install_bin ./procs
}

# lazygit -- jesseduffield/lazygit, tag HAS leading v; asset embeds version w/o v
sm_install_lazygit() {
   local v; v="$(sm_nov "$(sm_resolve_version "${LAZYGIT_VERSION:-}" jesseduffield/lazygit)")"
   sm_banner lazygit "$v"; sm_workdir lazygit >/dev/null
   sm_fetch_extract "https://github.com/jesseduffield/lazygit/releases/download/v${v}/lazygit_${v}_Linux_x86_64.tar.gz"
   sm_install_bin ./lazygit
}

sm_main() {
   local tools=("$@")
   if (( ${#tools[@]} == 0 )); then
      tools=(ripgrep fd bat delta eza procs lazygit)
   fi
   for t in "${tools[@]}"; do "sm_install_${t}"; done
   completed "modern_linux_tools: done (${tools[*]})"
}
sm_main "$@"
# vim: ts=3 sts=3 sw=3 et
