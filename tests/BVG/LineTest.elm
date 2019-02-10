module BVG.LineTest exposing (suite)

import BVG.Line as Line exposing (Line)
import Expect exposing (Expectation)
import List exposing (head, length)
import Test exposing (..)


u1 =
    Line "U1" "#59ff00" "#fff"


emptyLine =
    Line "" "" ""


suite : Test
suite =
    describe "Line"
        [ describe "all"
            [ test "has the correct size" <| \() -> Expect.equal (length Line.all) 9
            , test "return line elements" <| \() -> Expect.equal (head Line.all) (Just u1)
            ]
        , describe "find"
            [ describe "when the input is within range"
                [ test "return the expected line" <| \() -> Expect.equal (Line.find 1) u1
                ]
            , describe "when the input out of range"
                [ test "return an empty line" <| \() -> Expect.equal (Line.find 100) emptyLine
                ]
            ]
        ]
