module Game.View exposing (view)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Game.State as State exposing (Action, State)
import Html exposing (Html, a, br, button, div, h1, h2, h3, p, text)
import Html.Attributes exposing (class, href, id, style, target, title)
import Html.Events exposing (onClick)
import List exposing (map)


viewLine : Station -> Line -> Html Action
viewLine station line =
    button
        [ class "line"
        , style "background-color" line.color.background
        , style "color" line.color.font
        , onClick (State.Verify station line)
        ]
        [ text line.name ]


viewScore : Int -> Html Action
viewScore s =
    div [ class "score" ] [ text (String.fromInt s), text " points" ]


viewTimeLeft : Int -> Html Action
viewTimeLeft s =
    div [ class "time" ] [ text (String.fromInt s), text " seconds left" ]


viewAnswer : Maybe Bool -> Html Action
viewAnswer b =
    case b of
        Nothing ->
            div [ class "answer", class "empty" ] [ text "Select a station!" ]

        Just True ->
            div [ class "answer", class "correct" ] [ text "Correct!" ]

        Just False ->
            div [ class "answer", class "incorrect" ] [ text "Incorrect!" ]


viewLines : List Line -> Station -> Html Action
viewLines lines station =
    div [ class "options" ] (map (viewLine station) lines)


viewStatus : Maybe Bool -> Int -> Int -> Html Action
viewStatus answer score time =
    div [ class "status" ]
        [ viewAnswer answer
        , viewScore score
        , viewTimeLeft time
        ]


viewLoading : Html Action
viewLoading =
    div [ class "title" ] [ h2 [] [ text "Loading" ] ]


viewError : String -> Html Action
viewError err =
    div [ class "title" ] [ h2 [ title err ] [ text "Error" ] ]


viewNotStarted : Html Action
viewNotStarted =
    div [ class "title" ] [ h2 [ class "start", onClick State.Start ] [ text "Start" ] ]


viewAsk : Station -> Html Action
viewAsk station =
    div [ class "title" ] [ h2 [] [ text station.name ] ]


viewFinished : Int -> Html Action
viewFinished score =
    div [ class "title" ]
        [ h2 [ class "final-score" ] [ text (String.fromInt score ++ " points!") ]
        , p [ class "congrats" ] [ text "Congrats!" ]
        , p [ class "try-again", onClick State.Home ] [ text "Try again" ]
        ]


viewFooter : Html Action
viewFooter =
    div [ id "footer" ]
        [ h3 [ class "logo" ] [ text "BVGame" ]
        , div [ id "navbar" ]
            [ p []
                [ text "made with 💛 by "
                , a [ href "https://github.com/marceloboeira", target "_blank" ] [ text "marceloboeira" ]
                ]
            , p []
                [ a [ href "https://github.com/marceloboeira/BVGame", target "_blank" ] [ text "source code" ]
                ]
            ]
        ]


viewBody : State -> Html Action
viewBody state =
    div [ id "body" ]
        (case state.step of
            State.Loading ->
                [ viewLoading ]

            State.Error e ->
                [ viewError e ]

            State.NotStarted ->
                [ viewNotStarted ]

            State.Ask station ->
                [ viewAsk station
                , viewLines state.lines station
                , viewStatus state.lastAnswer state.score state.timeLeft
                ]

            State.Finished ->
                [ viewFinished state.score ]
        )


view : State -> Html Action
view state =
    div [ id "application" ]
        [ viewBody state
        , viewFooter
        ]
