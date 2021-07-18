{ pkgs ? import ./nix { } }:

pkgs.mkShell {
  name = "purescript-monrach";
  buildInputs = with pkgs; [ nodejs-16_x purescript ];
}
