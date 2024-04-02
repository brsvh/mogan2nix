{ fetchgit, lib, makeWrapper, stdenv, ... }:
stdenv.mkDerivation {
  pname = "s7";

  version = import ./version.nix;

  meta = {
    description = "A Scheme interpreter";

    homepage = "https://ccrma.stanford.edu/software/s7/";

    license = lib.licenses.bsd0;

    longDescription = ''
      s7 is a Scheme interpreter intended as an extension language for other
      applications. It is an extension language of Snd and sndlib (snd), Rick Taube's
      Common Music (commonmusic at sourceforge), Kjetil Matheussen's Radium music
      editor, and Iain Duncan's Scheme for Max (or Pd).
    '';

    # TODO add maintainer before create PR to NixOS/nixpkgs.

    platforms = lib.platforms.all;
  };

  src = fetchgit {
    url = "https://cm-gitlab.stanford.edu/bil/s7.git";
    rev = import ./rev.nix;
    hash = import ./hash.nix;
  };

  buildInputs = [ makeWrapper ];

  env.NIX_CFLAGS_COMPILE = toString [ "-Wl,-export-dynamic" "-I." "-fPIC" ];

  NIX_CFLAGS_LINK = [ "-ldl" "-lm" ];

  buildPhase = ''
    # compile libs7.so
    mkdir -p $out/lib
    gcc -c s7.c -o s7.o -DS7_LOAD_PATH="\"$out/lib\""
    gcc -shared -o libs7.so s7.o
    cp libs7.so $out/lib/

    # REVIEW: should we directly compile s7 repl from s7.c with its main?
    #         like: gcc -o s7 s7.c -DWITH_MAIN -DS7_LOAD_PATH="\"$out/lib\""
    gcc -L$out/lib -o s7 repl.c -DS7_LOAD_PATH="\"$out/lib\"" -ls7

    # generate libc_s7.c and compile libc_s7.so
    ./s7 libc.scm
  '';

  installPhase = ''
    mkdir -p $out/{bin,include,lib,share}
    mkdir -p $out/share/s7

    cp s7 $out/bin/s7-unwrapped
    cp libc_s7.so $out/lib/
    cp s7.h $out/include/s7.h
    cp *.scm $out/share/s7/
    cp -r tools $out/share/s7/

    makeWrapper $out/bin/s7-unwrapped $out/bin/s7 --chdir $out/share/s7
  '';

  passthru.updateScript = ./update.sh;
}
