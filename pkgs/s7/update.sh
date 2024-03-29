#!/usr/bin/env sh
#! nix-shell -i bash -p nix-prefetch-git jq

repo="https://cm-gitlab.stanford.edu/bil/s7.git"

oldrev=$(cat rev.nix)
newrev="\"$(curl -sSL https://cm-gitlab.stanford.edu/api/v4/projects/182/repository/commits/master | jq -r '.id')\""

if [ "$oldrev" != "$newrev" ]; then
  echo "\"0-unstable-$(date +%Y-%m-%d)\"" > version.nix
  echo "\"$newrev\"" > rev.nix
  hash=$(nix-prefetch-git --url $repo --rev $newrev --quiet | jq -r '.hash')
  echo "\"$hash\"" > hash.nix
fi
