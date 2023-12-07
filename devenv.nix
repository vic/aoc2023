{ pkgs, ... }:

{
  # https://devenv.sh/basics/
  #env.GREET = "devenv";

  # https://devenv.sh/packages/
  packages = with pkgs; [
    aoc-cli
    xh
    watchexec
    just
    helix
    jq
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
  # languages.ocaml.enable = true;
  languages.scala.enable = true;
  languages.nix.enable = true;
  languages.unison.enable = true;

  languages.ocaml.packages = pkgs.ocaml-ng.ocamlPackages_5_1;
  languages.java.jdk.package = pkgs.graalvm-ce;
  # https://devenv.sh/pre-commit-hooks/
  # pre-commit.hooks.shellcheck.enable = true;

  # https://devenv.sh/processes/
  # processes.ping.exec = "ping example.com";

  # See full reference at https://devenv.sh/reference/options/
}
