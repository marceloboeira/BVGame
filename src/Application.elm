module Application exposing (Action(..), State, init, main, update, view, viewAnswer, viewLine, viewScore)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Browser
import Debug exposing (log)
import Html exposing (Html, br, button, div, h1, h2, text)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import Http
import List exposing (head, map, member, sortBy, tail)
import Random exposing (Generator)
import String


type Step
    = Loading
    | NotStarted
    | Started
    | Finished


type alias State =
    { question : Maybe Station
    , lines : List Line
    , stations : List Station
    , step : Step
    , lastAnswer : Maybe Bool
    , round : Int
    , score : Int
    }


type Action
    = Home
    | GotLinesData (Result Http.Error (List Line))
    | GotStationsData (Result Http.Error (List Station))
    | Start
    | Verify Line


init : ( State, Cmd Action )
init =
  -- TODO use Cmd.batch
    ( State Nothing [] [] Loading Nothing 0 0, Line.fetch "./data/lines.json" GotLinesData )


update : Action -> State -> ( State, Cmd Action )
update action state =
    case action of
        Home ->
            init

        GotLinesData (Ok l) ->
            ( { state | lines = sortBy .name l }, Station.fetch "./data/stations.json" GotStationsData )

        GotLinesData (Err _) ->
            ( { state | lines = [] }, Cmd.none )

        GotStationsData (Ok s) ->
            ( { state | step = NotStarted, stations = s }, Cmd.none )

        GotStationsData (Err _) ->
            ( { state | stations = [] }, Cmd.none )

        Start ->
            let
                f =
                    case tail state.stations of
                        Just s ->
                            s

                        Nothing ->
                            []
            in
            ( { state | step = Started, question = head state.stations, stations = f }, Cmd.none )

        Verify l ->
            let
                f =
                    case tail state.stations of
                        Just s ->
                            s

                        Nothing ->
                            []

                newRound =
                    state.round + 1

                newStep =
                    if state.round >= 5 then
                        Finished

                    else
                        Started

                answer =
                    case state.question of
                        Nothing ->
                            False

                        Just station ->
                            member l station.lines

                score =
                    case answer of
                        True ->
                            state.score + 1

                        False ->
                            state.score
            in
            ( { state
                | lastAnswer = Just answer
                , score = score
                , question = head state.stations
                , stations = f
                , step = newStep
                , round = newRound
              }
            , Cmd.none
            )


viewLine : Line -> Html Action
viewLine l =
    button
        [ class "line"
        , style "background-color" l.color.background
        , style "color" l.color.font
        , onClick (Verify l)
        ]
        [ text l.name ]


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


viewOptions : List Line -> Html Action
viewOptions l =
    div [ class "options" ] (map viewLine l)


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

            Started ->
                case state.question of
                    Nothing ->
                        [ text "This should never happen" ]

                    Just question ->
                        [ div [ class "title" ] [ h2 [] [ text question.name ] ]
                        , viewStatus state.lastAnswer state.score
                        , viewOptions state.lines
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
