{
  description = "Blog Phoenix app";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    flake-utils.lib.eachDefaultSystem (
      system: let
        pkgs = import nixpkgs {inherit system;};
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
            sha256 = "sha256-f5eYiS98laTyXod/ZpTjeKVv0b9AxAYfh2o9qlrCAIg=";
          };

          postBuild = ''
            pushd assets

            NODE_PATH="$PWD/../deps:$PWD/../_build/prod" \
            ${pkgs.esbuild}/bin/esbuild js/app.js \
              --bundle --target=es2022 \
              --outdir=../priv/static/assets/js \
              --external:/fonts/* --external:/images/* \
              --alias:@=. \
              --minify

            popd

            ${pkgs.tailwindcss_4}/bin/tailwindcss \
              --input=assets/css/app.css \
              --output=priv/static/assets/css/app.css \
              --minify

            mix phx.digest

          '';
          postInstall = ''
            wrapProgram $out/bin/blog --set RELEASE_COOKIE "blog-cookie"
          '';

          nativeBuildInputs = with pkgs; [esbuild tailwindcss_4 makeWrapper];
        };
      in {
        packages.default = blog;

        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            erlang
            elixir
            elixir-ls
            tailwindcss_4
          ];

          shellHook = ''
            echo "$(elixir --version | grep "Elixir")"
            export TAILWINDCSS_PATH="${pkgs.lib.getExe pkgs.tailwindcss_4}"
          '';
        };
      }
    );
}
