{-
Welcome to a Spago project!
You can edit this file as you like.
-}
{ name = "my-project"
, dependencies =
  [ "aff"
  , "console"
  , "effect"
  , "monarch"
  , "prelude"
  , "psci-support"
  , "run"
  , "typelevel-prelude"
  , "web-dom"
  , "web-html"
  , "maybe"
  , "nullable"
  , "undefined"
  , "variant"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
