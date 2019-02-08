module BVG.LineTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)

import List exposing (length, head)
import BVG.Line as Line exposing (Line)

suite : Test
suite =
  describe "Line" [
    describe "all" [
      test "has the correct size" <| \() -> Expect.equal (length Line.all) 9
      , test "return line elements" <| \() -> Expect.equal (head Line.all) (Just (Line "U1" "#59ff00")) ]
    , describe "find" [
        describe "when the input is within range" [
          test "return the expected line" <| \() -> Expect.equal (Line.find 1) (Line "U1" "#59ff00") ]
          , describe "when the input out of range" [
            test "return an empty line" <| \() -> Expect.equal (Line.find 100) (Line "" "")
          ] ] ]
