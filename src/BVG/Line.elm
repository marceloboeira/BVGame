module BVG.Line exposing (Color, Line, decoder, fetch)

import Http
import Json.Decode exposing (Decoder, field, list, map2, map3, string)
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


fetch : String -> (Result Http.Error (List Line) -> a) -> Cmd a
fetch url action =
    Http.get
        { url = url
        , expect = Http.expectJson action (list decoder)
        }
