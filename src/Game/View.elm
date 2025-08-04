module Game.View exposing (view)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)
import Game.Score as Score exposing (GameMode(..))
import Game.State as State exposing (Action, State)
import Html exposing (Html, a, br, button, div, h1, h2, h3, p, span, text)
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


viewScore : Int -> Bool -> Bool -> Html Action
viewScore s effect plusOneAnim =
    let
        scoreClass =
            if effect then
                "score score-effect"

            else
                "score"
    in
    div [ class scoreClass ]
        [ div [ class "score-number" ] [ text (String.fromInt s) ]
        , div [ class "score-label" ] [ text "POINTS" ]
        , if plusOneAnim then
            span [ class "plus-one" ] [ text "+1" ]

          else
            text ""
        ]


viewTimeLeft : Int -> GameMode -> Html Action
viewTimeLeft s gameMode =
    let
        timeStr =
            if s < 10 then
                "0" ++ String.fromInt s

            else
                String.fromInt s

        label =
            case gameMode of
                Classic ->
                    "SECONDS"

                Survival ->
                    "ROUND"

                TimeAttack ->
                    "SECONDS"
    in
    div [ class "timeboard-time" ]
        [ div [ class "time-number" ] [ text timeStr ]
        , div [ class "time-label" ] [ text label ]
        ]


viewAnswer : Maybe Bool -> Html Action
viewAnswer b =
    case b of
        Nothing ->
            div [ class "answer", class "empty" ] [ text "Select a station!" ]

        Just True ->
            div [ class "answer", class "correct" ] [ text "Correct!" ]

        Just False ->
            div [ class "answer", class "incorrect" ] [ text "Incorrect!" ]


viewLines : List Line -> Station -> Bool -> Html Action
viewLines lines station canGuess =
    div [ class "options" ] (List.indexedMap (\index line -> viewLineWithNumber station index line canGuess) lines)


viewLineWithNumber : Station -> Int -> Line -> Bool -> Html Action
viewLineWithNumber station index line canGuess =
    let
        number =
            index + 1

        buttonClass =
            if canGuess then
                "line"

            else
                "line disabled"
    in
    button
        [ class buttonClass
        , style "background-color" line.color.background
        , style "color" line.color.font
        , onClick (State.Verify station line)
        ]
        [ text line.name ]


viewStatus : Maybe Bool -> Int -> Int -> Bool -> Bool -> GameMode -> Bool -> Html Action
viewStatus answer score time effect plusOneAnim gameMode canGuess =
    div [ class "status" ]
        [ viewAnswer answer
        , viewScore score effect plusOneAnim
        , viewTimeLeft time gameMode
        ]


viewLoading : Html Action
viewLoading =
    div [ class "title" ] [ h2 [] [ text "Loading" ] ]


viewError : String -> Html Action
viewError err =
    div [ class "title" ] [ h2 [ title err ] [ text "Error" ] ]


viewCountdown : Int -> Html Action
viewCountdown count =
    let
        countText =
            if count > 0 then
                String.fromInt count

            else
                "GO!"

        countClass =
            if count > 0 then
                "countdown-number"

            else
                "countdown-go"
    in
    div [ class "countdown-screen" ]
        [ div [ class countClass ] [ text countText ]
        ]


viewHome : Int -> Html Action
viewHome lastScore =
    div [ class "home-screen" ]
        [ div [ class "game-container" ]
            [ h2 [ class "game-title" ] [ text "BVGame" ]
            , if lastScore > 0 then
                div [ class "last-score" ] [ text ("Last Score: " ++ String.fromInt lastScore) ]

              else
                text ""
            , p [ class "game-instructions" ] [ text "Press SPACE to select mode" ]
            ]
        ]


viewModeSelection : { classic : Int, survival : Int, timeAttack : Int } -> Html Action
viewModeSelection highScores =
    div [ class "mode-selection" ]
        [ div [ class "game-container" ]
            [ h2 [ class "game-title" ] [ text "SELECT MODE" ]
            , div [ class "mode-buttons" ]
                [ button [ class "mode-btn classic", onClick (State.SelectMode Classic) ]
                    [ div [ class "mode-title" ] [ text "CLASSIC" ]
                    , div [ class "mode-desc" ] [ text "30 seconds, unlimited mistakes" ]
                    , div [ class "mode-high-score" ] [ text ("High Score: " ++ String.fromInt highScores.classic) ]
                    ]
                , button [ class "mode-btn survival", onClick (State.SelectMode Survival) ]
                    [ div [ class "mode-title" ] [ text "SURVIVAL" ]
                    , div [ class "mode-desc" ] [ text "5 seconds per round, one mistake = game over" ]
                    , div [ class "mode-high-score" ] [ text ("High Score: " ++ String.fromInt highScores.survival) ]
                    ]
                , button [ class "mode-btn timeattack", onClick (State.SelectMode TimeAttack) ]
                    [ div [ class "mode-title" ] [ text "TIME ATTACK" ]
                    , div [ class "mode-desc" ] [ text "30 seconds, fastest wins" ]
                    , div [ class "mode-high-score" ] [ text ("High Score: " ++ String.fromInt highScores.timeAttack) ]
                    ]
                ]
            ]
        ]


viewAsk : Station -> Maybe Bool -> Html Action
viewAsk station lastAnswer =
    let
        stationClass =
            case lastAnswer of
                Just True ->
                    "station-title correct-answer"

                Just False ->
                    "station-title wrong-answer"

                Nothing ->
                    "station-title"
    in
    div [ class stationClass ] [ h2 [] [ text station.name ] ]


viewFinished : Int -> GameMode -> { classic : Int, survival : Int, timeAttack : Int } -> Html Action
viewFinished score gameMode highScores =
    let
        currentHighScore =
            case gameMode of
                Classic ->
                    highScores.classic

                Survival ->
                    highScores.survival

                TimeAttack ->
                    highScores.timeAttack

        isNewRecord =
            score > currentHighScore

        recordClass =
            if isNewRecord then
                "new-record"

            else
                ""
    in
    div [ class "title" ]
        [ h2 [ class ("final-score " ++ recordClass) ] [ text (String.fromInt score ++ " POINTS!") ]
        , if isNewRecord then
            p [ class "new-record-label" ] [ text "NEW RECORD! 🎉" ]

          else
            p [ class "high-score" ] [ text ("High Score: " ++ String.fromInt currentHighScore ++ " POINTS") ]
        , p [ class "congrats" ] [ text "Congrats!" ]
        , p [ class "try-again", onClick State.HomeAction ] [ text "Try again" ]
        ]


viewGameStatus : Int -> Int -> GameMode -> Bool -> Html Action
viewGameStatus score timeLeft gameMode plusOneAnim =
    let
        timeClass =
            if timeLeft <= 10 then
                "status-value time-value urgent"

            else
                "status-value time-value"
    in
    div [ class "persistent-game-status" ]
        [ div [ class "game-status-item" ]
            [ span [ class "status-label" ] [ text "SCORE" ]
            , div [ class "score-container" ]
                [ span [ class "status-value score-value" ] [ text (String.fromInt score) ]
                , if plusOneAnim then
                    span [ class "plus-one" ] [ text "+1" ]

                  else
                    text ""
                ]
            ]
        , div [ class "game-status-item" ]
            [ span [ class "status-label" ] [ text "TIME" ]
            , span [ class timeClass ] [ text (String.fromInt timeLeft) ]
            ]
        ]


viewHighScores : { classic : Int, survival : Int, timeAttack : Int } -> Html Action
viewHighScores highScores =
    div [ class "persistent-high-scores" ]
        [ div [ class "high-score-item" ]
            [ span [ class "mode-label" ] [ text "CLASSIC" ]
            , span [ class "score-value" ] [ text (String.fromInt highScores.classic) ]
            ]
        , div [ class "high-score-item" ]
            [ span [ class "mode-label" ] [ text "SURVIVAL" ]
            , span [ class "score-value" ] [ text (String.fromInt highScores.survival) ]
            ]
        , div [ class "high-score-item" ]
            [ span [ class "mode-label" ] [ text "TIME ATTACK" ]
            , span [ class "score-value" ] [ text (String.fromInt highScores.timeAttack) ]
            ]
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

            State.Home ->
                [ viewHome state.lastScore ]

            State.ModeSelection ->
                [ viewModeSelection state.highScores ]

            State.NotStarted ->
                [ viewHome state.lastScore ]

            State.Countdown count ->
                [ viewCountdown count ]

            State.Ask station ->
                [ div [ class "game-board" ]
                    [ viewAsk station state.lastAnswer
                    , viewLines state.lines station state.canGuess
                    ]
                ]

            State.Finished ->
                [ viewFinished state.score state.gameMode state.highScores ]
        )


view : State -> Html Action
view state =
    let
        bottomSection =
            case state.step of
                State.Ask _ ->
                    viewGameStatus state.score state.timeLeft state.gameMode state.plusOneAnim

                State.Countdown _ ->
                    viewGameStatus 0 state.timeLeft state.gameMode state.plusOneAnim

                _ ->
                    viewHighScores state.highScores
    in
    div [ id "application" ]
        [ viewBody state
        , bottomSection
        , viewFooter
        ]
