module Game.State exposing (Action(..), State, Step(..), fetchLines, fetchStations, init, shuffle, update)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Http
import List exposing (map, member, sortBy, take)
import Random exposing (Generator)
import Random.List
import String
import Time


type Step
    = Loading
    | Error String
    | NotStarted
    | Ask Station
    | Finished


type Action
    = Home
    | Tick Time.Posix
    | GotLinesData (Result Http.Error (List Line))
    | GotStationsData (Result Http.Error (List Station))
    | GotShuffledStations (List Station)
    | Start
    | Verify Station Line
    | KeyPress String


type alias State =
    { lines : List Line
    , stations : List Station
    , step : Step
    , lastAnswer : Maybe Bool
    , score : Int
    , timeLeft : Int
    }


roundTime : Int
roundTime =
    30


handleNumberKey : Int -> State -> ( State, Cmd Action )
handleNumberKey number state =
    case state.step of
        Ask station ->
            let
                selectedLine =
                    List.head (List.drop (number - 1) state.lines)
            in
            case selectedLine of
                Just line ->
                    update (Verify station line) state

                Nothing ->
                    ( state, Cmd.none )

        _ ->
            ( state, Cmd.none )


fetchLines : Cmd Action
fetchLines =
    Line.fetch "./data/lines.json" GotLinesData


fetchStations : Cmd Action
fetchStations =
    Station.fetch "./data/stations.json" GotStationsData


shuffle : List Station -> Cmd Action
shuffle stations =
    Random.generate GotShuffledStations (Random.List.shuffle stations)


init : ( State, Cmd Action )
init =
    ( State [] [] Loading Nothing 0 roundTime, fetchLines )


update : Action -> State -> ( State, Cmd Action )
update action state =
    case action of
        Home ->
            init

        GotLinesData (Ok l) ->
            ( { state | lines = sortBy .name l }, fetchStations )

        GotLinesData (Err _) ->
            ( { state | step = Error "Couldn't load lines" }, Cmd.none )

        GotStationsData (Ok stations) ->
            ( state, shuffle stations )

        GotStationsData (Err _) ->
            ( { state | step = Error "Couldn't load stations" }, Cmd.none )

        GotShuffledStations stations ->
            ( { state | step = NotStarted, stations = stations }, Cmd.none )

        Tick _ ->
            case state.step of
                Ask _ ->
                    let
                        time =
                            state.timeLeft - 1
                    in
                    if time <= 0 then
                        ( { state | step = Finished }, Cmd.none )

                    else
                        ( { state | timeLeft = time }, Cmd.none )

                _ ->
                    ( state, Cmd.none )

        Start ->
            case state.stations of
                station :: stations ->
                    ( { state | step = Ask station, stations = stations }, Cmd.none )

                [] ->
                    ( { state | step = Error "Couldn't start the game" }, Cmd.none )

        Verify lastStation line ->
            let
                answer =
                    member line lastStation.lines

                lastAnswer =
                    Just answer

                score =
                    case answer of
                        True ->
                            state.score + 1

                        False ->
                            state.score
            in
            case state.stations of
                station :: stations ->
                    ( { state
                        | score = score
                        , lastAnswer = lastAnswer
                        , step = Ask station
                        , stations = stations
                      }
                    , Cmd.none
                    )

                [] ->
                    ( { state
                        | score = score
                        , lastAnswer = lastAnswer
                        , step = Finished
                      }
                    , Cmd.none
                    )

        KeyPress key ->
            case key of
                " " ->
                    case state.step of
                        NotStarted ->
                            update Start state

                        _ ->
                            ( state, Cmd.none )

                "1" ->
                    handleNumberKey 1 state

                "2" ->
                    handleNumberKey 2 state

                "3" ->
                    handleNumberKey 3 state

                "4" ->
                    handleNumberKey 4 state

                "5" ->
                    handleNumberKey 5 state

                "6" ->
                    handleNumberKey 6 state

                "7" ->
                    handleNumberKey 7 state

                "8" ->
                    handleNumberKey 8 state

                "9" ->
                    handleNumberKey 9 state

                _ ->
                    ( state, Cmd.none )
