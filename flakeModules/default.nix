top@{ ... }: {
  imports = [ 
    ./lean4-bin
  ];

  perSystem = sys@{ pkgs, config, self', ... }: {
    devenv.shells.default = import ./../devenv.nix sys;
  };
}
