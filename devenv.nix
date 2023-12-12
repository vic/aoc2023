{ pkgs, lib, self', ... }:

{
  # https://devenv.sh/basics/
  # env.LD_LIBRARY_PATH = lib.makeLibraryPath [ pkgs.stdenv.cc.cc ];

  # https://devenv.sh/packages/
  packages = with pkgs; [
    aoc-cli
    xh
    watchexec
    just
    helix
    jq
    lean4 # self'.packages.lean4-bin
    (flix.override { jre = pkgs.graalvm-ce; })
    nixpkgs-fmt
  ];

  # https://devenv.sh/scripts/
  #scripts.hello.exec = "echo hello from $GREET";

  enterShell = ''
  '';

  # https://devenv.sh/languages/
  languages.zig.enable = true;
  languages.rust.enable = true;
  languages.ocaml.enable = true;
  languages.scala.enable = true;
  languages.nix.enable = true;
  languages.unison.enable = true;
  languages.go.enable = true;

  languages.ocaml.packages = pkgs.ocaml-ng.ocamlPackages_5_1;
  languages.java.jdk.package = pkgs.graalvm-ce;
  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
