module Application exposing (Action(..), State, init, main, update, view, viewAnswer, viewLine, viewScore)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Browser
import Html exposing (Html, button, div, h1, h2, text)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import List exposing (map, member)
import String


type alias State =
    { question : Station, lastAnswer : Maybe Bool, score : Int }


type Action
    = First
    | Verify Line


init : State
init =
    State (Station.find 0) Nothing 0


update : Action -> State -> State
update action state =
    case action of
        First ->
            State (Station.find 1) Nothing 0

        Verify l ->
            let
                answer =
                    member l state.question.lines

                score =
                    case answer of
                        True ->
                            state.score + 1

                        False ->
                            state.score
            in
            State (Station.find 1) (Just answer) score


viewLine : Line -> Html Action
viewLine l =
    button [ class "line", style "background-color" l.color, onClick (Verify l) ] [ text l.name ]


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


view : State -> Html Action
view state =
    div [ id "application" ]
        [ div [ id "header" ] [ h1 [] [ text "BVGame" ] ]
        , div [ id "body" ]
            [ div [ class "title" ] [ h2 [] [ text state.question.name ] ]
            , div [ class "status" ]
                [ viewAnswer state.lastAnswer
                , viewScore state.score
                ]
            , div [ class "options" ] (map viewLine Line.all)
            ]
        ]


main =
    Browser.sandbox
        { init = init
        , update = update
        , view = view
        }
