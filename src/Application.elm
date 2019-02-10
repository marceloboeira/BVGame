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
    { question : Maybe Station, lastAnswer : Maybe Bool, score : Int }


type Action
    = Home
    | Start
    | Verify Line


init : ( State, Cmd Action )
init =
    ( State Nothing Nothing 0
    , Cmd.none
    )


update : Action -> State -> ( State, Cmd Action )
update action state =
    case action of
        Home ->
            ( state, Cmd.none )

        Start ->
            ( { state | question = Just (Station.find 0) }, Cmd.none )

        Verify l ->
            let
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
            ( { state | question = Just (Station.find score), lastAnswer = Just answer, score = score }, Cmd.none )


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


viewOptions : List Line -> Html Action
viewOptions l =
    div [ class "options" ] (map viewLine Line.all)


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
        (case state.question of
            Nothing ->
                [ div [ class "title" ] [ h2 [ class "start", onClick Start ] [ text "Start" ] ] ]

            Just question ->
                [ div [ class "title" ] [ h2 [] [ text question.name ] ]
                , viewStatus state.lastAnswer state.score
                , viewOptions Line.all
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
