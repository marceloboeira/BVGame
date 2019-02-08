module BVG.StationTest exposing (..)

import Expect exposing (Expectation)
import Test exposing (..)

import List exposing (length, head)
import BVG.Station as Station exposing (Station)
import BVG.Line as Line exposing (Line)

suite : Test
suite =
  describe "Station" [
    describe "all" [
      test "has the correct size" <| \() -> Expect.equal (length Station.all) 6
      , test "return line elements" <| \() -> Expect.equal (head Station.all) (Just (Station "Stadtmitte" [Line.find 2, Line.find 6])) ]
    , describe "find" [
        describe "when the input is within range" [
          test "return the expected station" <| \() -> Expect.equal (Station.find 0) (Station "Stadtmitte" [Line.find 2, Line.find 6]) ]
          , describe "when the input out of range" [
            test "return an empty station" <| \() -> Expect.equal (Station.find 100) (Station "" [])
          ] ] ]
