module Game.State exposing (Action(..), State, Step(..), fetchLines, fetchStations, init, rounds, shuffle, update)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Http
import List exposing (map, member, sortBy, take)
import Random exposing (Generator)
import Random.List
import String


type Step
    = Loading
    | NotStarted
    | Ask Station
    | Finished


type Action
    = Home
    | GotLinesData (Result Http.Error (List Line))
    | GotStationsData (Result Http.Error (List Station))
    | GotShuffledStations (List Station)
    | Start
    | Verify Station Line


type alias State =
    { lines : List Line
    , stations : List Station
    , step : Step
    , lastAnswer : Maybe Bool
    , score : Int
    }


rounds : Int
rounds =
    5


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
    ( State [] [] Loading Nothing 0, fetchLines )


update : Action -> State -> ( State, Cmd Action )
update action state =
    case action of
        Home ->
            init

        GotLinesData (Ok l) ->
            ( { state | lines = sortBy .name l }, fetchStations )

        GotLinesData (Err _) ->
            ( state, Cmd.none )

        GotStationsData (Ok stations) ->
            ( state, shuffle stations )

        GotStationsData (Err _) ->
            ( state, Cmd.none )

        GotShuffledStations stations ->
            ( { state | step = NotStarted, stations = take rounds stations }, Cmd.none )

        Start ->
            case state.stations of
                station :: stations ->
                    ( { state | step = Ask station, stations = stations }, Cmd.none )

                [] ->
                    ( { state | step = Loading }, Cmd.none )

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
