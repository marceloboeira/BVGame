module Game.StateTest exposing (suite)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Expect exposing (Expectation)
import Game.State as State exposing (Action, State)
import Http
import Test exposing (..)
import Tuple


baseState =
    Tuple.first State.init


sampleStation1 =
    Station "1" "a" sortedLines


sampleStation2 =
    Station "2" "b" sortedLines


sampleStation3 =
    Station "3" "c" sortedLines


unshuffledStations =
    [ sampleStation1, sampleStation2, sampleStation3 ]


shuffledStations =
    [ sampleStation3, sampleStation1, sampleStation2 ]


lineA =
    Line "a6" "a" (Line.Color "" "")


lineU =
    Line "a7" "u" (Line.Color "" "")


unsortedLines =
    [ Line "a4" "b" (Line.Color "" "")
    , Line "a6" "a" (Line.Color "" "")
    , Line "a1" "d" (Line.Color "" "")
    ]


sortedLines =
    [ Line "a6" "a" (Line.Color "" "")
    , Line "a4" "b" (Line.Color "" "")
    , Line "a1" "d" (Line.Color "" "")
    ]


suite : Test
suite =
    describe "State"
        [ describe "init"
            [ test "return the default state" <|
                \() ->
                    baseState
                        |> Expect.equal (State [] [] State.Loading Nothing 0)
            , test "triggers lines to be fetched" <|
                \() ->
                    State.init
                        |> Tuple.second
                        |> Expect.equal State.fetchLines
            ]
        , describe "update"
            [ describe "when Home"
                [ test "does not change the state" <|
                    \() ->
                        baseState
                            |> State.update State.Home
                            |> Tuple.first
                            |> Expect.equal (Tuple.first State.init)
                , test "triggers lines to be fetched" <|
                    \() ->
                        baseState
                            |> State.update State.Home
                            |> Tuple.second
                            |> Expect.equal (Tuple.second State.init)
                ]
            , describe "when GotLinesData"
                [ describe "and the result is successful"
                    [ test "updates lines on state" <|
                        \() ->
                            baseState
                                |> State.update (State.GotLinesData (Ok unsortedLines))
                                |> Tuple.first
                                |> .lines
                                |> Expect.equal sortedLines
                    , test "trigger stations fetch" <|
                        \() ->
                            baseState
                                |> State.update (State.GotLinesData (Ok unsortedLines))
                                |> Tuple.second
                                |> Expect.equal State.fetchStations
                    ]
                , describe "and the result is not sucessfull"
                    [ test "does nothing" <|
                        \() ->
                            State.init
                                |> Tuple.first
                                |> State.update (State.GotLinesData (Result.Err Http.NetworkError))
                                |> Expect.equal ( Tuple.first State.init, Cmd.none )
                    ]
                ]
            , describe "when GotStationsData"
                [ describe "and the result is successful"
                    [ test "does not update the state" <|
                        \() ->
                            State.init
                                |> Tuple.first
                                |> State.update (State.GotStationsData (Ok unshuffledStations))
                                |> Tuple.first
                                |> .stations
                                |> Expect.notEqual unshuffledStations
                    , test "trigger shuffle stations" <|
                        \() ->
                            State.init
                                |> Tuple.first
                                |> State.update (State.GotStationsData (Ok unshuffledStations))
                                |> Tuple.second
                                |> Expect.notEqual Cmd.none

                    -- TODO: fix this test, it doesn't work with (State.shuffle(unshuffledStations))
                    ]
                , describe "and the result is not sucessfull"
                    [ test "does nothing" <|
                        \() ->
                            State.init
                                |> Tuple.first
                                |> State.update (State.GotStationsData (Result.Err Http.NetworkError))
                                |> Expect.equal ( Tuple.first State.init, Cmd.none )
                    ]
                , describe "when GotShuffledStations"
                    [ test "updates stations on state" <|
                        \() ->
                            State.init
                                |> Tuple.first
                                |> State.update (State.GotShuffledStations shuffledStations)
                                |> Tuple.first
                                |> .stations
                                |> Expect.equal shuffledStations
                    , test "update step on state" <|
                        \() ->
                            State.init
                                |> Tuple.first
                                |> State.update (State.GotShuffledStations shuffledStations)
                                |> Tuple.first
                                |> .step
                                |> Expect.equal State.NotStarted
                    ]
                ]
            , describe "when Start"
                [ describe "and the state is ready"
                    [ test "update state to Ask" <|
                        \() ->
                            { baseState | stations = unshuffledStations }
                                |> State.update State.Start
                                |> Tuple.first
                                |> .step
                                |> Expect.equal (State.Ask sampleStation1)
                    , test "update stations with the tail" <|
                        \() ->
                            { baseState | stations = unshuffledStations }
                                |> State.update State.Start
                                |> Tuple.first
                                |> .stations
                                |> Expect.equal [ sampleStation2, sampleStation3 ]
                    ]
                , describe "and the state is not ready"
                    [ test "set the step to Loading" <|
                        \() ->
                            { baseState | stations = [] }
                                |> State.update State.Start
                                |> Tuple.first
                                |> .step
                                |> Expect.equal State.Loading
                    ]
                ]
            , describe "when Verify"
                [ describe "and it is not the last round"
                    [ test "update the state setting the step to Ask (head of stations)" <|
                        \() ->
                            { baseState | stations = shuffledStations }
                                |> State.update (State.Verify sampleStation1 lineA)
                                |> Tuple.first
                                |> .step
                                |> Expect.equal (State.Ask sampleStation3)
                    , test "update the state setting the stations to tail of stations" <|
                        \() ->
                            { baseState | stations = shuffledStations, score = 0 }
                                |> State.update (State.Verify sampleStation1 lineA)
                                |> Tuple.first
                                |> .stations
                                |> Expect.equal [ sampleStation1, sampleStation2 ]
                    , describe "and the answer is correct"
                        [ test "update the state with the last answer true" <|
                            \() ->
                                { baseState | stations = shuffledStations }
                                    |> State.update (State.Verify sampleStation1 lineA)
                                    |> Tuple.first
                                    |> .lastAnswer
                                    |> Expect.equal (Just True)
                        , test "update the state increasing the score by 1" <|
                            \() ->
                                { baseState | stations = shuffledStations, score = 0 }
                                    |> State.update (State.Verify sampleStation1 lineA)
                                    |> Tuple.first
                                    |> .score
                                    |> Expect.equal 1
                        ]
                    , describe "and the answer is not correct"
                        [ test "update the sate with the last answer false" <|
                            \() ->
                                { baseState | stations = shuffledStations }
                                    |> State.update (State.Verify sampleStation1 lineU)
                                    |> Tuple.first
                                    |> .lastAnswer
                                    |> Expect.equal (Just False)
                        , test "does not update the score" <|
                            \() ->
                                { baseState | stations = shuffledStations, score = 0 }
                                    |> State.update (State.Verify sampleStation1 lineU)
                                    |> Tuple.first
                                    |> .score
                                    |> Expect.equal 0
                        ]
                    ]
                , describe "and it is the last round"
                    [ test "set the step to Finished" <|
                        \() ->
                            { baseState | stations = [] }
                                |> State.update (State.Verify sampleStation1 lineA)
                                |> Tuple.first
                                |> .step
                                |> Expect.equal State.Finished
                    , describe "and the answer is correct"
                        [ test "update the state with the last answer true" <|
                            \() ->
                                { baseState | stations = [] }
                                    |> State.update (State.Verify sampleStation1 lineA)
                                    |> Tuple.first
                                    |> .lastAnswer
                                    |> Expect.equal (Just True)
                        , test "update the state increasing the score by 1" <|
                            \() ->
                                { baseState | stations = [], score = 0 }
                                    |> State.update (State.Verify sampleStation1 lineA)
                                    |> Tuple.first
                                    |> .score
                                    |> Expect.equal 1
                        ]
                    , describe "and the answer is not correct"
                        [ test "update the sate with the last answer false" <|
                            \() ->
                                { baseState | stations = [] }
                                    |> State.update (State.Verify sampleStation1 lineU)
                                    |> Tuple.first
                                    |> .lastAnswer
                                    |> Expect.equal (Just False)
                        , test "does not update the score" <|
                            \() ->
                                { baseState | stations = [], score = 0 }
                                    |> State.update (State.Verify sampleStation1 lineU)
                                    |> Tuple.first
                                    |> .score
                                    |> Expect.equal 0
                        ]
                    ]
                ]
            ]
        ]
