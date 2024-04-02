final: pkgs: let inherit (pkgs) callPackage; in { s7 = callPackage ./s7 { }; }
