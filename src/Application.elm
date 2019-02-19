module Application exposing (main)

import Browser
import Game.State as State exposing (Action, State)
import Game.View as View
import Time


subscriptions : State -> Sub Action
subscriptions staate =
    Time.every 1000 State.Tick


main =
    Browser.element
        { init = \() -> State.init
        , update = State.update
        , view = View.view
        , subscriptions = subscriptions
        }
