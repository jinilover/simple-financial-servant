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
      # genAttrs :: [String] -> (String -> any) -> AttrSet
      forAllSystems = f: nixpkgs.lib.genAttrs allSystems (system: f 
        { pkgs = nixpkgs.legacyPackages.${system}; }
        # nixpkgs.legacyPackages.${system}
      );
    in
    {
      packages = forAllSystems ( { pkgs }: rec {
      # packages = forAllSystems (  pkgs : rec {
        haskellPackages = pkgs.haskellPackages;
        
        # Build the Haskell package from the cabal file
        simple-financial-servant = haskellPackages.callCabal2nix "simple-financial-servant" ./. { };
        
        # Default package to build
        default = simple-financial-servant;
      });

      # Development environment output
      devShells = forAllSystems ( { pkgs }: rec {
      # devShells = forAllSystems (  pkgs : rec {
        default = pkgs.mkShell {
          packages = with pkgs; [
            # Haskell toolchain (available directly from pkgs, not from haskell.packages.*)
            ghc
            cabal-install
            haskell-language-server # hlint is part of hls
            # System/library packages
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
