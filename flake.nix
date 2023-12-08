{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    devenv.url = "github:cachix/devenv";
    mk-shell-bin.url = "github:rrbutani/nix-mk-shell-bin";
    nix2container.url = "github:nlewo/nix2container";
    nix2container.inputs.nixpkgs.follows = "nixpkgs";

    lean4-bin-x86_64-darwin.url = "https://github.com/leanprover/lean4/releases/download/v4.4.0-rc1/lean-4.4.0-rc1-darwin.zip";
    lean4-bin-x86_64-darwin.flake = false;
  };

  outputs = inputs@{ nixpkgs, flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = nixpkgs.lib.systems.flakeExposed;
      imports = [ inputs.devenv.flakeModule ./flakeModules ];
    };
}
