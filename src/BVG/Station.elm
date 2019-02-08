module BVG.Station exposing (..)

import BVG.Line as Line exposing(Line)
import List.Extra exposing (getAt)

type alias Station = { name : String, lines : List Line }

-- TODO: Load from a JSON file
all : List Station
all = [
  Station "Stadtmitte" [Line.find 2, Line.find 6]
  , Station "Alexanderplatz" [Line.find 2, Line.find 5, Line.find 8]
  , Station "Schönhauser-Alle" [Line.find 2]
  , Station "Büllowstrasse" [Line.find 2]
  , Station "Hallesches Tor" [Line.find 1, Line.find 3, Line.find 6]
  , Station "Möckernbrücke" [Line.find 1, Line.find 3, Line.find 7]
  ]

find : Int -> Station
find x =
  case getAt x all of
    Just l -> l
    Nothing -> Station "" []
