# mogan2nix

Provisional, experimental Mogan STEM Suite release/pre-release packaging.

## Software to be packaged

- [ ] Mogan Research `mogan-research`
- [ ] Mogan Code `mogan-code`
- [ ] Mogan Beamer `mogan-beamer`

As dependencies:

- [ ] Lolly (a library for GNU TeXmacs) `lolly`.
- [x] s7 Scheme `s7`

## Testing

> [!NOTE]
> Make sure you are using NixOS unstable.

### Flakes

Just add this repo to your flake inputs.

### No flakes

Add this repo as a channel, then include `<mogan2nix/nixosModules/nixos.nix>` in your imports list. Adding the repo as a channel can be done with e.g.

``` shell
sudo nix-channel --add https://github.com/brsvh/mogan2nix/archive/main.tar.gz mogan2nix
sudo nix-channel --update mogan2nix
```

