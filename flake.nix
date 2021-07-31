{
  description = "PureScript Monarch";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-21.05";
    utils.url = "github:numtide/flake-utils";
  };

  outputs = { utils, nixpkgs, ... }:
    utils.lib.eachDefaultSystem (system:
      let pkgs = import nixpkgs { inherit system; };
      in
      {
        devShell = import ./shell.nix { inherit pkgs; };
      });
}
