module BVG.LineTest exposing (suite)

import BVG.Line as Line exposing (Line)
import Expect exposing (Expectation)
import Json.Decode exposing (Decoder)
import Test exposing (..)


suite : Test
suite =
    describe "Line"
        [ describe "decoder"
            [ describe "when the input is valid"
                [ test "return a decoded line" <|
                    \() ->
                        let
                            input =
                                """
                                {
                                  "id": "a23",
                                  "name": "U1",
                                  "color": {
                                    "background": "#000",
                                    "font": "#000"
                                  }
                                }
                                """

                            output =
                                Json.Decode.decodeString Line.decoder input
                        in
                        Expect.equal output
                            (Ok
                                { id = "a23"
                                , name = "U1"
                                , color =
                                    { background = "#000"
                                    , font = "#000"
                                    }
                                }
                            )
                ]
            , describe "when the input is invalid"
                [ test "return an error" <|
                    \() ->
                        let
                            input =
                                """
                                { invalid }
                                """

                            output =
                                Json.Decode.decodeString Line.decoder input
                        in
                        Expect.err output
                ]
            ]
        ]
