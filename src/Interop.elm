module Interop exposing (OutgoingData(..), TaggedValue, encodeOut)

import Json.Encode


type alias TaggedValue =
    { tag : String, data : Json.Encode.Value }


type OutgoingData
    = LogError String
    | ApiUrl String


encodeOut : OutgoingData -> TaggedValue
encodeOut info =
    case info of
        ApiUrl url ->
            { tag = "API_URL"
            , data = Json.Encode.string url
            }

        LogError err ->
            { tag = "LOG_ERROR"
            , data = Json.Encode.string err
            }
