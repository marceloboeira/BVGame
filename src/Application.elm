module Application exposing (Action(..), State, init, main, update, view, viewAnswer, viewLine, viewScore)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Browser
import Debug exposing (log)
import Html exposing (Html, br, button, div, h1, h2, text)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
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


type alias State =
    { lines : List Line
    , stations : List Station
    , step : Step
    , lastAnswer : Maybe Bool
    , score : Int
    }


type Action
    = Home
    | GotLinesData (Result Http.Error (List Line))
    | GotStationsData (Result Http.Error (List Station))
    | GotShuffledStations (List Station)
    | Start
    | Verify Station Line



-- Number of game rounds


rounds : Int
rounds =
    5


fetchLines : Cmd Action
fetchLines =
    Line.fetch "./data/lines.json" GotLinesData


fetchStations : Cmd Action
fetchStations =
    Station.fetch "./data/stations.json" GotStationsData


init : ( State, Cmd Action )
init =
    -- TODO use Cmd.batch
    ( State [] [] Loading Nothing 0, fetchLines )


shuffle : List Station -> Cmd Action
shuffle stations =
    Random.generate GotShuffledStations (Random.List.shuffle stations)


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

                _ ->
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

                _ ->
                    ( { state
                        | score = score
                        , lastAnswer = lastAnswer
                        , step = Finished
                      }
                    , Cmd.none
                    )


viewLine : Station -> Line -> Html Action
viewLine station line =
    button
        [ class "line"
        , style "background-color" line.color.background
        , style "color" line.color.font
        , onClick (Verify station line)
        ]
        [ text line.name ]


viewScore : Int -> Html Action
viewScore s =
    div [ class "score" ] [ text "Score: ", text (String.fromInt s) ]


viewAnswer : Maybe Bool -> Html Action
viewAnswer b =
    case b of
        Nothing ->
            div [ class "answer", class "empty" ] [ text "Select a station below:" ]

        Just True ->
            div [ class "answer", class "correct" ] [ text "Correct!" ]

        Just False ->
            div [ class "answer", class "incorrect" ] [ text "Incorrect!" ]


viewOptions : List Line -> Station -> Html Action
viewOptions lines station =
    div [ class "options" ] (map (viewLine station) lines)


viewStatus : Maybe Bool -> Int -> Html Action
viewStatus answer score =
    div [ class "status" ]
        [ viewAnswer answer
        , viewScore score
        ]


viewHeader : Html Action
viewHeader =
    div [ id "header" ] [ h1 [] [ text "BVGame" ] ]


viewBody : State -> Html Action
viewBody state =
    div [ id "body" ]
        (case state.step of
            Loading ->
                [ div [ class "title" ] [ h2 [] [ text "Loading" ] ] ]

            NotStarted ->
                [ div [ class "title" ] [ h2 [ class "start", onClick Start ] [ text "Start" ] ] ]

            Ask station ->
                [ div [ class "title" ] [ h2 [] [ text station.name ] ]
                , viewStatus state.lastAnswer state.score
                , viewOptions state.lines station
                ]

            Finished ->
                [ div [ class "title" ]
                    [ h2 [ class "start", onClick Home ]
                        [ text "Congratulations!"
                        , br [] []
                        , text ("You have scored " ++ String.fromInt state.score ++ " points!")
                        ]
                    ]
                ]
        )


view : State -> Html Action
view state =
    div [ id "application" ]
        [ viewHeader
        , viewBody state
        ]


main =
    Browser.element
        { init = \() -> init
        , update = update
        , view = view
        , subscriptions = \_ -> Sub.none
        }
