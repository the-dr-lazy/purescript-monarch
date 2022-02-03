{-|
Module     : Monarch.Type.Symbol
Maintainer : Mohammad Hasani (the-dr-lazy.github.io) <the-dr-lazy@pm.me>
Copyright  : (c) 2020-2022 Monarch
License    : MPL 2.0

This Source Code Form is subject to the terms of the Mozilla Public
License, version 2.0. If a copy of the MPL was not distributed with this
file, You can obtain one at http://mozilla.org/MPL/2.0/.
-}

module Monarch.Type.Symbol (class SwitchCase, class TitleCase) where

import Prim.Symbol as Symbol

class SwitchCase :: Symbol -> Symbol -> Constraint
class SwitchCase lower upper | lower -> upper, upper -> lower

instance SwitchCase "0" "0"
else instance SwitchCase "1" "1"
else instance SwitchCase "2" "2"
else instance SwitchCase "3" "3"
else instance SwitchCase "4" "4"
else instance SwitchCase "5" "5"
else instance SwitchCase "6" "6"
else instance SwitchCase "7" "7"
else instance SwitchCase "8" "8"
else instance SwitchCase "9" "9"
else instance SwitchCase "a" "A"
else instance SwitchCase "b" "B"
else instance SwitchCase "c" "C"
else instance SwitchCase "d" "D"
else instance SwitchCase "e" "E"
else instance SwitchCase "f" "F"
else instance SwitchCase "g" "G"
else instance SwitchCase "h" "H"
else instance SwitchCase "i" "I"
else instance SwitchCase "j" "J"
else instance SwitchCase "k" "K"
else instance SwitchCase "l" "L"
else instance SwitchCase "m" "M"
else instance SwitchCase "n" "N"
else instance SwitchCase "o" "O"
else instance SwitchCase "p" "P"
else instance SwitchCase "q" "Q"
else instance SwitchCase "r" "R"
else instance SwitchCase "s" "S"
else instance SwitchCase "t" "T"
else instance SwitchCase "u" "U"
else instance SwitchCase "v" "V"
else instance SwitchCase "w" "W"
else instance SwitchCase "x" "X"
else instance SwitchCase "y" "Y"
else instance SwitchCase "z" "Z"
else instance
  ( Symbol.Cons lower_head lower_tail lower
  , SwitchCase lower_head upper_head
  , SwitchCase lower_tail upper_tail
  , Symbol.Cons upper_head upper_tail upper
  ) =>
  SwitchCase lower upper

class TitleCase :: Symbol -> Symbol -> Constraint
class TitleCase input output | input -> output

instance
  ( Symbol.Cons input_head output_tail input
  , SwitchCase input_head output_head
  , Symbol.Append output_head output_tail output
  ) =>
  TitleCase input output
