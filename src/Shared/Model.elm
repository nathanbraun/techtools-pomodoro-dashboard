module Shared.Model exposing (Model)

import Api.Health exposing (AppStatus)
import Time


{-| -}
type alias Model =
    { timezone : Time.Zone
    , time : Time.Posix
    , displayAggregated : Bool
    , apiUrl : Maybe String
    , licenseKey : Maybe String
    , showTestData : Bool
    , appStatus : AppStatus
    }
