port module Game.Score exposing (GameMode(..), ScoreMsg(..), decodeHighScore, encodeScore, getHighScore, getHighScorePort, saveScore, saveScorePort)

import Json.Decode as Decode
import Json.Encode as Encode


type GameMode
    = Classic
    | Survival
    | TimeAttack


type ScoreMsg
    = SaveScore GameMode Int
    | GetHighScore GameMode
    | HighScoreReceived GameMode Int


getHighScore : GameMode -> Int
getHighScore mode =
    -- Default to 0, will be updated via port
    0


saveScore : GameMode -> Int -> Cmd ScoreMsg
saveScore mode score =
    Cmd.none



-- Ports for cookie handling


port saveScorePort : Encode.Value -> Cmd msg


port getHighScorePort : (Decode.Value -> msg) -> Sub msg


encodeScore : GameMode -> Int -> Encode.Value
encodeScore mode score =
    Encode.object
        [ ( "mode", encodeGameMode mode )
        , ( "score", Encode.int score )
        ]


encodeGameMode : GameMode -> Encode.Value
encodeGameMode mode =
    Encode.string <|
        case mode of
            Classic ->
                "classic"

            Survival ->
                "survival"

            TimeAttack ->
                "timeattack"


decodeHighScore : Decode.Decoder ( GameMode, Int )
decodeHighScore =
    Decode.map2 Tuple.pair
        (Decode.field "mode" decodeGameMode)
        (Decode.field "highScore" Decode.int)


decodeGameMode : Decode.Decoder GameMode
decodeGameMode =
    Decode.string
        |> Decode.andThen
            (\str ->
                case str of
                    "classic" ->
                        Decode.succeed Classic

                    "survival" ->
                        Decode.succeed Survival

                    "timeattack" ->
                        Decode.succeed TimeAttack

                    _ ->
                        Decode.fail ("Unknown game mode: " ++ str)
            )
