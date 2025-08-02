module Application exposing (main)

import Browser
import Browser.Events
import Game.State as State exposing (Action, State)
import Game.View as View
import Json.Decode as Decode
import Time


subscriptions : State -> Sub Action
subscriptions state =
    Sub.batch
        [ Time.every 1000 State.Tick
        , Browser.Events.onKeyDown (Decode.map State.KeyPress keyDecoder)
        ]


keyDecoder : Decode.Decoder String
keyDecoder =
    Decode.field "key" Decode.string


main =
    Browser.element
        { init = \() -> State.init
        , update = State.update
        , view = View.view
        , subscriptions = subscriptions
        }
