top@{ inputs, ... }: {
  perSystem = { pkgs, config, system, ... }:
    let
      archive = inputs."lean4-bin-${system}";
      lean4-bin = pkgs.stdenvNoCC.mkDerivation {
        name = "lean4-bin";
        version = "4.4.0-rc1"; 
        src = archive;
        nativeBuildInputs = with pkgs; [ makeWrapper ];
        installPhase = ''
        mkdir -p $out/bin
        makeWrapper $src/bin/lean $out/bin/lean         --prefix PATH : $src/bin
        makeWrapper $src/bin/lake $out/bin/lake         --prefix PATH : $src/bin
        makeWrapper $src/bin/leanc $out/bin/leanc       --prefix PATH : $src/bin
        makeWrapper $src/bin/leanmake $out/bin/leanmake --prefix PATH : $src/bin
        '';
      };
    in
    {
      packages = { inherit lean4-bin; };
    };
}
