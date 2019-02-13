module BVG.StationTest exposing (suite)

import BVG.Station as Station exposing (Station)
import Expect exposing (Expectation)
import Json.Decode exposing (Decoder)
import Test exposing (..)


suite : Test
suite =
    describe "Station"
        [ describe "decoder"
            [ describe "when the input is valid"
                [ test "return a decoded station" <|
                    \() ->
                        let
                            input =
                                """
                                {
                                  "id": "d29",
                                  "name": "Stadtmitte",
                                  "lines": [{
                                    "id": "a23",
                                    "name": "U2",
                                    "color": {
                                      "background": "#000",
                                      "font": "#000"
                                    }
                                  }]
                                }
                                """

                            output =
                                Json.Decode.decodeString Station.decoder input
                        in
                        Expect.equal output
                            (Ok
                                { id = "d29"
                                , name = "Stadtmitte"
                                , lines =
                                    [ { id = "a23"
                                      , name = "U2"
                                      , color =
                                            { background = "#000"
                                            , font = "#000"
                                            }
                                      }
                                    ]
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
                                Json.Decode.decodeString Station.decoder input
                        in
                        Expect.err output
                ]
            ]
        ]
