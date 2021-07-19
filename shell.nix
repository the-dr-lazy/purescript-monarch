{ pkgs ? import ./nix { } }:

let
  nodePackages = with pkgs.nodePackages; [
    typescript
    typescript-language-server
    purescript-language-server
    prettier
    yaml-language-server
    vscode-html-languageserver-bin
    parcel-bundler
  ];

in pkgs.mkShell {
  name = "purescript-monarch";
  buildInputs = with pkgs;
    nodePackages ++ [ gitFull niv nodejs-16_x purescript spago headroom ];
}
