module BVG.Line exposing (Line, decoder)

import Json.Decode exposing (Decoder, field, map2, map3, string)
import List.Extra exposing (getAt)


type alias Color =
    { background : String
    , font : String
    }


type alias Line =
    { id : String
    , name : String
    , color : Color
    }


colorDecoder : Decoder Color
colorDecoder =
    map2 Color
        (field "background" string)
        (field "font" string)


decoder : Decoder Line
decoder =
    map3 Line
        (field "id" string)
        (field "name" string)
        (field "color" colorDecoder)
