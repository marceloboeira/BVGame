module BVG.Line exposing (..)

import List.Extra exposing (getAt)

type alias Line = { name : String , color : String }

-- TODO: Load from a JSON file
all : List Line
all = [
  Line "U1" "#59ff00"
  , Line "U2" "#ff3300"
  , Line "U3" "#00ff66"
  , Line "U4" "#ffe600"
  , Line "U5" "#664019"
  , Line "U6" "#4d66ff"
  , Line "U7" "#33ccff"
  , Line "U8" "#0061da"
  , Line "U9" "#ff7300"
  ]

find : Int -> Line
find x =
  case getAt (x - 1) all of
    Just l -> l
    Nothing -> Line "" ""
