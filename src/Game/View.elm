module Game.View exposing (view)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Game.State as State exposing (Action, State)
import Html exposing (Html, br, button, div, h1, h2, text)
import Html.Attributes exposing (class, id, style, title)
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


viewLines : List Line -> Station -> Html Action
viewLines lines station =
    div [ class "options" ] (map (viewLine station) lines)


viewStatus : Maybe Bool -> Int -> Html Action
viewStatus answer score =
    div [ class "status" ]
        [ viewAnswer answer
        , viewScore score
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
        [ h2 [ class "start", onClick State.Home ]
            [ text "Congratulations!"
            , br [] []
            , text ("You have scored " ++ String.fromInt score ++ " points!")
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
                , viewStatus state.lastAnswer state.score
                , viewLines state.lines station
                ]

            State.Finished ->
                [ viewFinished state.score ]
        )


viewHeader : Html Action
viewHeader =
    div [ id "header" ] [ h1 [] [ text "BVGame" ] ]


view : State -> Html Action
view state =
    div [ id "application" ]
        [ viewHeader
        , viewBody state
        ]
