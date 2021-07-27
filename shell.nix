{ pkgs ? import ./nix { } }:

pkgs.mkShell {
  name = "purescript-monarch";

  buildInputs = builtins.concatMap builtins.attrValues [
    ###################################################
    # Code styles:
    {
      inherit (pkgs) pre-commit headroom nixpkgs-fmt nix-linter shfmt shellcheck;
      inherit (pkgs.python3Packages) pre-commit-hooks yamllint;
      inherit (pkgs.nodePackages) prettier;
    }

    ###################################################
    # Command line tools:
    {
      inherit (pkgs) gitFull;
      inherit (pkgs.nodePackages) parcel-bundler;
    }

    ###################################################
    # Languages:
    {
      inherit (pkgs) dhall purescript nodejs-16_x;
      inherit (pkgs.nodePackages) typescript;
    }

    ###################################################
    # Language servers:
    {
      inherit (pkgs) dhall-lsp-server;
      inherit (pkgs.nodePackages)
        purescript-language-server
        typescript-language-server
        vscode-html-languageserver-bin
        vscode-json-languageserver-bin
        yaml-language-server;
    }

    ###################################################
    # Package managers:
    { inherit (pkgs) niv spago; }
  ];
}
