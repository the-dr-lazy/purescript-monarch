{ name = "monarch"
, license = "MPL"
, repository = "https://github.com/thebrodmann/monarch"
, dependencies =
  [ "aff"
  , "effect"
  , "run"
  , "refs"
  , "record"
  , "unsafe-reference"
  , "unsafe-coerce"
  , "console"
  , "psci-support"
  , "web-html"
  , "web-dom"
  , "web-uievents"
  , "typelevel-prelude"
  , "strings"
  , "undefined"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
