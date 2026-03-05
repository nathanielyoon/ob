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
          ob = pkgs.stdenv.mkDerivation (final: {
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
              pkgs.pnpm.configHook
              pkgs.pnpm
            ];
            pnpmDeps = pkgs.pnpm.fetchDeps {
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
          default = self.packages.${system}.ob;
        }
      );
      overlays = {
        ob = _: prev: { ob = self.packages.${prev.stdenv.hostPlatform.system}.ob; };
        default = self.overlays.ob;
      };
    };
}
