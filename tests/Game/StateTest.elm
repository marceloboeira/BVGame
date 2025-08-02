module Game.StateTest exposing (suite)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Expect exposing (Expectation)
import Game.State as State exposing (Action, State)
import Http
import Test exposing (..)
import Time
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
                        |> Expect.equal (State [] [] State.Loading Nothing 0 30)
            , test "trigger lines to be fetched" <|
                \() ->
                    State.init
                        |> Tuple.second
                        |> Expect.equal State.fetchLines
            ]
        , describe "update"
            [ describe "when Home"
                [ test "do not change the state" <|
                    \() ->
                        baseState
                            |> State.update State.Home
                            |> Tuple.first
                            |> Expect.equal (Tuple.first State.init)
                , test "trigger lines to be fetched" <|
                    \() ->
                        baseState
                            |> State.update State.Home
                            |> Tuple.second
                            |> Expect.equal (Tuple.second State.init)
                ]
            , describe "when GotLinesData"
                [ describe "and the result is successful"
                    [ test "update lines on state" <|
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
                    [ test "update the state with step to Error" <|
                        \() ->
                            State.init
                                |> Tuple.first
                                |> State.update (State.GotLinesData (Result.Err Http.NetworkError))
                                |> Tuple.first
                                |> .step
                                |> Expect.equal (State.Error "Couldn't load lines")
                    ]
                ]
            , describe "when GotStationsData"
                [ describe "and the result is successful"
                    [ test "do not update the state" <|
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
                    [ test "update the state with step to Error" <|
                        \() ->
                            State.init
                                |> Tuple.first
                                |> State.update (State.GotStationsData (Result.Err Http.NetworkError))
                                |> Tuple.first
                                |> .step
                                |> Expect.equal (State.Error "Couldn't load stations")
                    ]
                , describe "when GotShuffledStations"
                    [ test "update stations on state" <|
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
                    [ test "update the state with step to Error " <|
                        \() ->
                            { baseState | stations = [] }
                                |> State.update State.Start
                                |> Tuple.first
                                |> .step
                                |> Expect.equal (State.Error "Couldn't start the game")
                    ]
                ]
            , describe "when Tick"
                [ describe "and the state is Ask"
                    [ describe "and there is still time left"
                        [ test "update the state decreasing the timeLeft" <|
                            \() ->
                                { baseState | step = State.Ask sampleStation1, timeLeft = 10 }
                                    |> State.update (State.Tick (Time.millisToPosix 1000))
                                    |> Tuple.first
                                    |> .timeLeft
                                    |> Expect.equal 9
                        ]
                    , describe "and there is no time left"
                        [ test "update the state with step to Finished" <|
                            \() ->
                                { baseState | step = State.Ask sampleStation1, timeLeft = 1 }
                                    |> State.update (State.Tick (Time.millisToPosix 1000))
                                    |> Tuple.first
                                    |> .step
                                    |> Expect.equal State.Finished
                        ]
                    ]
                , describe "and the state is not Ask"
                    [ test "do not update the state" <|
                        \() ->
                            baseState
                                |> State.update (State.Tick (Time.millisToPosix 1000))
                                |> Tuple.first
                                |> Expect.equal baseState
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
                        , test "do not update the score" <|
                            \() ->
                                { baseState | stations = shuffledStations, score = 0 }
                                    |> State.update (State.Verify sampleStation1 lineU)
                                    |> Tuple.first
                                    |> .score
                                    |> Expect.equal 0
                        ]
                    ]
                , describe "and it is the last round"
                    [ test "update the state with the step Finished" <|
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
                        , test "do not update the score" <|
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
        , describe "when KeyPress"
            [ describe "when pressing space"
                [ describe "and the state is NotStarted"
                    [ test "start the game" <|
                        \() ->
                            { baseState | step = State.NotStarted, stations = unshuffledStations }
                                |> State.update (State.KeyPress " ")
                                |> Tuple.first
                                |> .step
                                |> Expect.equal (State.Ask sampleStation1)
                    ]
                , describe "and the state is not NotStarted"
                    [ test "do not change the state" <|
                        \() ->
                            { baseState | step = State.Ask sampleStation1 }
                                |> State.update (State.KeyPress " ")
                                |> Tuple.first
                                |> Expect.equal { baseState | step = State.Ask sampleStation1 }
                    ]
                ]
            , describe "when pressing number keys"
                [ describe "and the state is Ask"
                    [ test "select line 1 when pressing 1" <|
                        \() ->
                            { baseState | step = State.Ask sampleStation1, lines = sortedLines }
                                |> State.update (State.KeyPress "1")
                                |> Tuple.first
                                |> .lastAnswer
                                |> Expect.equal (Just True)
                    , test "select line 2 when pressing 2" <|
                        \() ->
                            { baseState | step = State.Ask sampleStation1, lines = sortedLines }
                                |> State.update (State.KeyPress "2")
                                |> Tuple.first
                                |> .lastAnswer
                                |> Expect.equal (Just True)
                    , test "select line 3 when pressing 3" <|
                        \() ->
                            { baseState | step = State.Ask sampleStation1, lines = sortedLines }
                                |> State.update (State.KeyPress "3")
                                |> Tuple.first
                                |> .lastAnswer
                                |> Expect.equal (Just True)
                    , test "do nothing when pressing invalid number" <|
                        \() ->
                            { baseState | step = State.Ask sampleStation1, lines = sortedLines }
                                |> State.update (State.KeyPress "0")
                                |> Tuple.first
                                |> Expect.equal { baseState | step = State.Ask sampleStation1, lines = sortedLines }
                    ]
                , describe "and the state is not Ask"
                    [ test "do not change the state" <|
                        \() ->
                            { baseState | step = State.NotStarted }
                                |> State.update (State.KeyPress "1")
                                |> Tuple.first
                                |> Expect.equal { baseState | step = State.NotStarted }
                    ]
                ]
            , describe "when pressing other keys"
                [ test "do not change the state" <|
                    \() ->
                        baseState
                            |> State.update (State.KeyPress "a")
                            |> Tuple.first
                            |> Expect.equal baseState
                ]
            ]
        ]
