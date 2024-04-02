let
  overlay = import ./pkgs;
  pkgs = import <nixpkgs> { overlays = [ overlay ]; };
in pkgs
