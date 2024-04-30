module Interop exposing (OutgoingData(..), TaggedValue, encodeOut)

import Json.Encode


type alias TaggedValue =
    { tag : String, data : Json.Encode.Value }


type OutgoingData
    = LogError String
    | ApiUrl String
    | LicenseKey String


encodeOut : OutgoingData -> TaggedValue
encodeOut info =
    case info of
        ApiUrl url ->
            { tag = "API_URL"
            , data = Json.Encode.string url
            }

        LicenseKey key ->
            { tag = "LICENSE_KEY"
            , data = Json.Encode.string key
            }

        LogError err ->
            { tag = "LOG_ERROR"
            , data = Json.Encode.string err
            }
