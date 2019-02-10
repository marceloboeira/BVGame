module BVG.Line exposing (Line, all, find)

import List.Extra exposing (getAt)


type alias Line =
    { name : String
    , backgroundColor : String
    , fontColor : String
    }



-- TODO: Load from a JSON file


all : List Line
all =
    [ Line "U1" "#59ff00" "#fff"
    , Line "U2" "#ff3300" "#fff"
    , Line "U3" "#00ff66" "#fff"
    , Line "U4" "#ffe600" "#000"
    , Line "U5" "#664019" "#fff"
    , Line "U6" "#4d66ff" "#fff"
    , Line "U7" "#33ccff" "#fff"
    , Line "U8" "#0061da" "#fff"
    , Line "U9" "#ff7300" "#fff"
    ]


find : Int -> Line
find x =
    case getAt (x - 1) all of
        Just l ->
            l

        Nothing ->
            Line "" "" ""
