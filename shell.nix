{ pkgs }:

pkgs.stable.mkShell {
  name = "Monarch";

  nativeBuildInputs = builtins.concatMap builtins.attrValues [
    ###################################################
    # Code styles:
    {
      inherit (pkgs.stable) pre-commit nixpkgs-fmt nix-linter shfmt shellcheck;
      inherit (pkgs.stable.python3Packages) pre-commit-hooks yamllint;
      inherit (pkgs.stable.nodePackages) prettier;

      headroom = pkgs.stable.haskell.lib.justStaticExecutables (pkgs.stable.haskellPackages.callHackage "headroom" "0.3.2.0" { });
    }

    ###################################################
    # Command line tools:
    {
      inherit (pkgs.stable) gitFull;
      inherit (pkgs.stable.nodePackages) parcel-bundler;
    }

    ###################################################
    # Languages:
    {
      inherit (pkgs.stable) dhall nodejs-16_x;
      inherit (pkgs.unstable) purescript;
      inherit (pkgs.stable.nodePackages) typescript;
    }

    ###################################################
    # Language servers:
    {
      inherit (pkgs.stable) dhall-lsp-server;
      inherit (pkgs.stable.nodePackages)
        bash-language-server
        purescript-language-server
        typescript-language-server
        vscode-html-languageserver-bin
        vscode-json-languageserver-bin
        yaml-language-server;
    }

    ###################################################
    # Package managers:
    { inherit (pkgs.unstable) spago; }
  ];
}
