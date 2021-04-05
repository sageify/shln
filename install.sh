#!/bin/sh

! command -v git >/dev/null && echo "Error: git is required." 1>&2 &&
  exit 1

grm_home="${GRM_HOME:-$HOME/src}/github.com/sageify/shln"
lnkn_home="${LNKN_HOME:-$HOME/bin}"

! [ -d "$grm_home" ] && mkdir -p -- "$grm_home" &&
  ! git clone -q --depth 1 https://github.com/sageify/shln.git "$grm_home" &&
  exit 1

! mkdir -p -- "$lnkn_home" &&
  exit 1

[ -f "$lnkn_home/lnkn" ] && rm -- "$lnkn_home/lnkn"
ln -s -- "$grm_home/lnkn.sh" "$lnkn_home/lnkn"

[ -f "$lnkn_home/shmod" ] && rm -- "$lnkn_home/shmod"
ln -s -- "$grm_home/shmod.sh" "$lnkn_home/shmod"

[ -f "$lnkn_home/grm" ] && rm -- "$lnkn_home/grm"
ln -s -- "$grm_home/grm.sh" "$lnkn_home/grm"

[ -f "$lnkn_home/shrm" ] && rm -- "$lnkn_home/shrm"
ln -s -- "$grm_home/shrm.sh" "$lnkn_home/shrm"

[ -f "$lnkn_home/envy" ] && rm -- "$lnkn_home/envy"
ln -s -- "$grm_home/envy.sh" "$lnkn_home/envy"

! [ -f "$HOME/.config/envy/.nvrc" ] && mkdir -p -- "$HOME/.config/envy" &&
  cat >"$HOME/.config/envy/.nvrc" <<'e0d16edb-6a1d-427a-893f-2693fa30e4a2'
PATH=$HOME/bin:$PATH
e0d16edb-6a1d-427a-893f-2693fa30e4a2

echo "Linkin (lnkn), Envy (nv), Groom (grm), Shmod (shmd), and Shroom (shrm) installed"
command -v lnkn >/dev/null &&
  exit 0

case $SHELL in
/bin/zsh)
  shell_profile=".zshrc"
  ;;
*)
  shell_profile=".bash_profile"
  ;;
esac

echo "Manually add sourcing of envy to your \$HOME/$shell_profile (or similar):"
echo ". ./bin/envy"
