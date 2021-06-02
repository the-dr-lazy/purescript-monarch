{ name = "monarch"
, license = "MPL"
, repository = "https://github.com/thebrodmann/monarch"
, dependencies =
  [ "aff"
  , "arrays"
  , "console"
  , "control"
  , "effect"
  , "foldable-traversable"
  , "maybe"
  , "newtype"
  , "prelude"
  , "psci-support"
  , "refs"
  , "run"
  , "strings"
  , "tuples"
  , "typelevel-prelude"
  , "undefined"
  , "unsafe-coerce"
  , "unsafe-reference"
  , "web-dom"
  , "web-html"
  , "web-uievents"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
