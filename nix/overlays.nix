{ system, sources }:

let
  headroom-exe =
    if system == "x86_64-darwin" then
      sources.headroom-darwin
    else if system == "x86_64-linux" then
      sources.headroom-linux
    else
      null;
in
[
  (final: _:
    {
      inherit sources;
      inherit (sources) niv;
      headroom =
        if headroom-exe != null then
          final.runCommand "headroom" { } ''
            mkdir -p $out/bin
            cp ${headroom-exe} $out/bin/headroom
            chmod +x $out/bin/headroom
          ''
        else
          throw "There is no Headroom executable for this system architecture.";
    })

  (_: _: {
    paths = {
      drv.root = builtins.path { path = ./..; name = "cascade"; };
      string.root = builtins.toString ./..;
    };
  })
]
