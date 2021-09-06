{ name, pkgs }:

pkgs.stable.mkShell {
  inherit name;

  nativeBuildInputs = builtins.concatMap builtins.attrValues [
    ###################################################
    # Code styles:
    {
      inherit (pkgs.stable)
        pre-commit
        purs-tidy
        nixpkgs-fmt
        nix-linter
        shfmt
        shellcheck;
      inherit (pkgs.unstable.python310Packages) pre-commit-hooks yamllint;
      inherit (pkgs.unstable.nodePackages) prettier;

      headroom = pkgs.stable.haskell.lib.justStaticExecutables (pkgs.stable.haskellPackages.callHackage "headroom" "0.3.2.0" { });
    }

    ###################################################
    # Command line tools:
    {
      inherit (pkgs.stable) cachix gitFull gitflow;
      inherit (pkgs.unstable.nodePackages) parcel-bundler lerna;
    }

    ###################################################
    # Languages:
    {
      inherit (pkgs.stable) dhall nodejs-16_x;
      inherit (pkgs.stable) purescript;
      inherit (pkgs.unstable.nodePackages) typescript;
    }

    ###################################################
    # Language servers:
    {
      inherit (pkgs.stable) dhall-lsp-server;
      inherit (pkgs.unstable.nodePackages)
        bash-language-server
        purescript-language-server
        typescript-language-server
        vscode-html-languageserver-bin
        vscode-json-languageserver-bin
        yaml-language-server;
    }

    ###################################################
    # Package managers:
    {
      inherit (pkgs.stable) spago pulp;
      inherit (pkgs.unstable.nodePackages) bower;
    }
  ];
}
