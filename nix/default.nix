{ system ? builtins.currentSystem, sources ? import ./sources.nix }:

import sources.nixpkgs {
  inherit system;
  config = { };
  overlays = import ./overlays.nix { inherit system sources; };
}
