{
  description = "E8, an editor that works the way Emacs works, from its releases";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      # Written by update.sh from E8's newest release; edit the script, not it.
      release = builtins.fromJSON (builtins.readFile ./release.json);
      forEachSystem = f: nixpkgs.lib.genAttrs (builtins.attrNames release.systems)
        (system: f nixpkgs.legacyPackages.${system} release.systems.${system});
    in
    {
      packages = forEachSystem (pkgs: assets: rec {
        e8 = pkgs.callPackage ./package.nix { inherit (release) version; inherit assets; };
        default = e8;
      });

      overlays.default = final: prev: {
        e8 = self.packages.${final.stdenv.hostPlatform.system}.e8;
      };
    };
}
