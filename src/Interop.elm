module Interop exposing (OutgoingData(..), TaggedValue, encodeOut)

import Json.Encode
import Json.Encode.Extra exposing (maybe)


type alias TaggedValue =
    { tag : String, data : Json.Encode.Value }


type OutgoingData
    = LogError String
    | ApiUrl (Maybe String)
    | LicenseKey (Maybe String)
    | TestDataFlag Bool


encodeOut : OutgoingData -> TaggedValue
encodeOut info =
    case info of
        ApiUrl url ->
            { tag = "API_URL"
            , data = maybe Json.Encode.string url
            }

        LicenseKey key ->
            { tag = "LICENSE_KEY"
            , data = maybe Json.Encode.string key
            }

        TestDataFlag flag ->
            { tag = "TEST_DATA_FLAG"
            , data = Json.Encode.bool flag
            }

        LogError err ->
            { tag = "LOG_ERROR"
            , data = Json.Encode.string err
            }
