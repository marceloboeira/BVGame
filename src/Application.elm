module Application exposing (main)

import Browser
import Game.State as State exposing (Action, State)
import Game.View as View


main =
    Browser.element
        { init = \() -> State.init
        , update = State.update
        , view = View.view
        , subscriptions = \_ -> Sub.none
        }
