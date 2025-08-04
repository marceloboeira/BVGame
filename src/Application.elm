module Application exposing (main)

import Browser
import Browser.Events
import Game.Score as Score exposing (GameMode(..), ScoreMsg(..))
import Game.State as State exposing (Action, State)
import Game.View as View
import Json.Decode as Decode
import Time


subscriptions : State -> Sub Action
subscriptions state =
    Sub.batch
        [ Time.every 1000 State.Tick
        , Browser.Events.onKeyDown (Decode.map State.KeyPress keyDecoder)
        , Score.getHighScorePort handleHighScorePort
        ]


keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string


handleHighScorePort : Decode.Value -> Action
handleHighScorePort value =
    case Decode.decodeValue decodeHighScores value of
        Ok highScores ->
            State.LoadAllHighScores highScores

        Err _ ->
            State.LoadAllHighScores { classic = 0, survival = 0, timeAttack = 0 }


decodeHighScores : Decode.Decoder { classic : Int, survival : Int, timeAttack : Int }
decodeHighScores =
    Decode.map3 (\c s t -> { classic = c, survival = s, timeAttack = t })
        (Decode.field "classic" Decode.int)
        (Decode.field "survival" Decode.int)
        (Decode.field "timeAttack" Decode.int)


main =
    Browser.element
        { init = \() -> State.init
        , update = State.update
        , view = View.view
        , subscriptions = subscriptions
        }
