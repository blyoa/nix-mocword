{
  description = "Nix flakes for mocword";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      self,
      nixpkgs,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs { inherit system; };

        mocword = pkgs.rustPlatform.buildRustPackage rec {
          pname = "mocword";
          version = "0.2.0";

          src = pkgs.fetchCrate {
            inherit pname version;
            hash = "sha256-DGQebd+doauYnrKrx0ejkwD8Cgcd6zsPad3mbSa0zXo=";
          };

          cargoHash = "sha256-BJJDjwasGBbFfQWfZC6msEVOewD0iNyZeF5MpXBN8iM=";
        };

        mocword-data = pkgs.fetchurl {
          name = "mocword.sqlite";
          url = "https://github.com/high-moctane/mocword-data/releases/download/eng20200217/mocword.sqlite.gz";
          hash = "sha256-oqUuN1YukI1NkbIc35XTmUZ322sQYTvKgoUTFFlnx9c=";
          nativeBuildInputs = [ pkgs.gzip ];
          postFetch = ''
            mv $out mocword.sqlite.gz
            gzip -dc mocword.sqlite.gz > $out
          '';
        };
      in
      {
        packages = {
          default = pkgs.buildEnv {
            name = "mocword";
            paths = [ ];
            nativeBuildInputs = [ pkgs.makeWrapper ];
            postBuild = ''
              makeWrapper ${mocword}/bin/mocword $out/bin/mocword \
                --set MOCWORD_DATA ${mocword-data}
            '';
          };
        };
      }
    );
}
