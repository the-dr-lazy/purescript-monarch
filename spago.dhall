{ name = "monarch"
, license = "MPL"
, repository = "https://github.com/thebrodmann/monarch"
, dependencies = [ "console", "effect", "psci-support" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
