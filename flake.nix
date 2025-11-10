{
  description = "A very basic flake";

  # Flake inputs
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/25.05";
  };

  #outputs = { self, nixpkgs }:
  outputs = { nixpkgs, ... }:
    let
      # Systems supported
      allSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f 
        { pkgs = nixpkgs.legacyPackages.${system}; }
        # nixpkgs.legacyPackages.${system}
      );
    in
    {
      # Development environment output
      devShells = forAllSystems ( { pkgs }: rec {
        haskellPackages = pkgs.haskell.packages.ghc;

        default = pkgs.mkShell {
          packages = with haskellPackages; with pkgs; [
            ghc
            cabal-install
            haskell-language-server # hlint is part of hls
            ## `pkgs` packages
            zlib 
            postgresql
            pkg-config
          ];

         shellHook = ''
           ln -sf "$(command -v haskell-language-server-wrapper)" "$PWD/haskell-language-server"
           export PATH=$PWD:$PATH
         '';
        };
      });
    };
}
