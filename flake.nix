{
  description = "Blog Phoenix app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    {
      nixosModules.default = import ./nix/module.nix self;
    }
    // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        beamPackages = pkgs.beam.packagesWith pkgs.beam.interpreters.erlang;

        blog = beamPackages.mixRelease {
          pname = "blog";
          version = "0.1.0";
          src = ./.;
          mixEnv = "prod";

          mixFodDeps = beamPackages.fetchMixDeps {
            pname = "blog-deps";
            version = "0.1.0";
            src = ./.;
            # Rode `nix build` uma vez — o erro mostra o hash correto.
            # Cole aqui o sha256 real.
            sha256 = pkgs.lib.fakeSha256;
          };

          # Assets: roda esbuild e tailwind direto, sem depender dos hex wrappers
          postBuild = ''
            pushd assets
            NODE_PATH="$MIX_DEPS_PATH" \
            ${pkgs.esbuild}/bin/esbuild js/app.js \
              --bundle --target=es2022 \
              --outdir=../priv/static/assets/js \
              --external:/fonts/* --external:/images/* \
              --alias:@=. \
              --minify
            popd

            ${pkgs.tailwindcss}/bin/tailwindcss \
              --input=assets/css/app.css \
              --output=priv/static/assets/css/app.css \
              --minify

            mix phx.digest
          '';
        };
      in
      {
        packages.default = blog;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            erlang
            elixir
            elixir-ls
          ];

          shellHook = ''
            echo "$(elixir --version | grep "Elixir")"
          '';
        };
      }
    );
}
