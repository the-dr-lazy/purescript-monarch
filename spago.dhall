{ name = "monarch"
, license = "MPL"
, repository = "https://github.com/thebrodmann/monarch"
, dependencies =
  [ "aff"
  , "effect"
  , "refs"
  , "record"
  , "unsafe-reference"
  , "unsafe-coerce"
  , "console"
  , "psci-support"
  , "web-html"
  , "web-dom"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
