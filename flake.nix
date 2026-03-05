{
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  outputs =
    { self, nixpkgs }:
    {
      packages = nixpkgs.lib.genAttrs nixpkgs.lib.systems.flakeExposed (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          obsidian-headless = pkgs.stdenv.mkDerivation (final: {
            pname = "obsidian-headless";
            version = "0.0.5";
            src = pkgs.fetchFromGitHub {
              owner = "obsidianmd";
              repo = "obsidian-headless";
              rev = "46e3d163a54fba39f3b8864045d02a58a3d4161a";
              hash = "sha256-4YwaWQu/257jBN4NsM3QObOp/e3AUcdrpCuGOo70EBk=";
            };
            nativeBuildInputs = [
              pkgs.nodejs
              pkgs.pnpmConfigHook
              pkgs.pnpm
            ];
            pnpmDeps = pkgs.fetchPnpmDeps {
              inherit (final) pname version src;
              fetcherVersion = 3;
              hash = "sha256-9XbLTX0ZM7GzRkNQ0IIKjuU7dIzzz3WvqfbBOFdIdmY=";
            };
            buildPhase = ''
              pnpm install
            '';
            installPhase = ''
              mkdir -p "$out/bin"
              cp -r btime node_modules package.json "$out/bin"
              cp cli.js "$out/bin/ob"
              chmod +x "$out/bin/ob"
            '';
          });
          default = self.packages.${system}.obsidian-headless;
        }
      );
      overlays = {
        obsidian-headless = _: prev: {
          obsidian-headless = self.packages.${prev.stdenv.hostPlatform.system}.obsidian-headless;
        };
        default = self.overlays.obsidian-headless;
      };
    };
}
