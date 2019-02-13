module BVG.Station exposing (Station, decoder, fetch)

import BVG.Line as Line exposing (Line)
import Http
import Json.Decode exposing (Decoder, field, list, map3, string)
import List.Extra exposing (getAt)


type alias Station =
    { id : String
    , name : String
    , lines : List Line
    }


decoder : Decoder Station
decoder =
    map3 Station
        (field "id" string)
        (field "name" string)
        (field "lines" (list Line.decoder))


fetch : String -> (Result Http.Error (List Station) -> a) -> Cmd a
fetch url action =
    Http.get
        { url = url
        , expect = Http.expectJson action (list decoder)
        }
