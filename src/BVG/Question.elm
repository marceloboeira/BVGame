module BVG.Question exposing (Question)

import BVG.Line as Line exposing (Line)
import BVG.Station as Station exposing (Station)


type alias Question =
    { station : Station }
