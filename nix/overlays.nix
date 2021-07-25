{ system, sources }:

let
  headroom-exe =
    if system == "x86_64-darwin" then
      sources.headroom-darwin
    else if system == "x86_64-linux" then
      sources.headroom-linux
    else
      null;
  mkHeadroom = pkgs:
    if headroom-exe != null then
      pkgs.runCommand "headroom" { } ''
        mkdir -p $out/bin
        cp ${headroom-exe} $out/bin/headroom
        chmod +x $out/bin/headroom
      ''
    else
      throw "There is no Headroom executable for this system architecture.";
in
[
  (final: _: { inherit sources; inherit (sources) niv; headroom = mkHeadroom final; })

  (_: _: {
    paths = {
      drv.root = builtins.path { path = ./..; name = "cascade"; };
      string.root = builtins.toString ./..;
    };
  })

  (final: _: {
    checks = (import sources.pre-commit-hooks).run {
      src = final.paths.string.root;

      tools = { inherit (final) nixpkgs-fmt nix-linter; };
      excludes = [ "nix/sources.nix$" ];

      hooks = {
        nixpkgs-fmt.enable = true;
        nix-linter.enable = true;

        headroom = {
          enable = true;
          name = "Check © headers";
          language = "system";
          pass_filenames = false;
          entry = "${final.headroom}/bin/headroom run";
          raw = {
            always_run = true;
          };
        };

        # Reference: https://github.com/pre-commit/pre-commit-hooks/blob/d0d9883648b4b30a43cd965471c9b5fa8f8a4131/.pre-commit-hooks.yaml#L24-L28
        check-case-conflict = {
          enable = true;
          name = "Check for case conflicts";
          description = "Check for files that would conflict in case-insensitive filesystems";
          language = "system";
          entry = "${final.python3Packages.pre-commit-hooks}/bin/check-case-conflict";
        };

        # Reference: https://github.com/pre-commit/pre-commit-hooks/blob/d0d9883648b4b30a43cd965471c9b5fa8f8a4131/.pre-commit-hooks.yaml#L42-L47
        check-json = {
          enable = true;
          name = "Check JSON";
          description = "This hook checks json files for parseable syntax.";
          language = "system";
          entry = "${final.python3Packages.pre-commit-hooks}/bin/check-json";
          types = [ "json" ];
        };

        # Reference: https://github.com/pre-commit/pre-commit-hooks/blob/d0d9883648b4b30a43cd965471c9b5fa8f8a4131/.pre-commit-hooks.yaml#L61-L66
        check-merge-conflict = {
          enable = true;
          name = "Check for merge conflicts";
          description = "Check for files that contain merge conflict strings.";
          language = "system";
          entry = "${final.python3Packages.pre-commit-hooks}/bin/check-merge-conflict";
          types = [ "text" ];

        };

        # Reference: https://github.com/pre-commit/pre-commit-hooks/blob/d0d9883648b4b30a43cd965471c9b5fa8f8a4131/.pre-commit-hooks.yaml#L67-L72
        check-symlinks = {
          enable = true;
          name = "Check for broken symlinks";
          description = "Checks for symlinks which do not point to anything.";
          language = "system";
          entry = "${final.python3Packages.pre-commit-hooks}/bin/check-symlinks";
          types = [ "symlink" ];
        };

        # Reference: https://github.com/pre-commit/pre-commit-hooks/blob/d0d9883648b4b30a43cd965471c9b5fa8f8a4131/.pre-commit-hooks.yaml#L79-L84
        check-vcs-permalinks = {
          enable = true;
          name = "Check vcs permalinks";
          description = "Ensures that links to vcs websites are permalinks.";
          language = "system";
          entry = "${final.python3Packages.pre-commit-hooks}/bin/check-vcs-permalinks";
          types = [ "text" ];
        };

        # Reference: https://github.com/pre-commit/pre-commit-hooks/blob/d0d9883648b4b30a43cd965471c9b5fa8f8a4131/.pre-commit-hooks.yaml#L91-L96
        check-yaml = {
          enable = true;
          name = "Check Yaml";
          description = "This hook checks yaml files for parseable syntax.";
          language = "system";
          entry = "${final.python3Packages.pre-commit-hooks}/bin/check-yaml";
          types = [ "yaml" ];

        };

        # Reference: https://github.com/pre-commit/pre-commit-hooks/blob/d0d9883648b4b30a43cd965471c9b5fa8f8a4131/.pre-commit-hooks.yaml#L127-L133
        end-of-file-fixer = {
          enable = true;
          name = "Fix End of Files";
          description = "Ensures that a file is either empty, or ends with one newline.";
          language = "system";
          entry = "${final.python3Packages.pre-commit-hooks}/bin/end-of-file-fixer";
          types = [ "text" ];
        };

        # Reference: https://github.com/pre-commit/pre-commit-hooks/blob/d0d9883648b4b30a43cd965471c9b5fa8f8a4131/.pre-commit-hooks.yaml#L187-L193
        trailing-whitespace = {
          enable = true;
          name = "Trim Trailing Whitespace";
          description = "This hook trims trailing whitespace.";
          language = "system";
          entry = "${final.python3Packages.pre-commit-hooks}/bin/trailing-whitespace-fixer";
          types = [ "text" ];
        };
      };
    };
  })
]
