module Shared.Model exposing (Model)

import Api.Http exposing (WebData)
import Api.Health exposing (AppStatus)
import Api.Project exposing (Project)
import RemoteData exposing (RemoteData)
import Time
import TimeZone


{-| -}
type alias Model =
    { timezone : RemoteData TimeZone.Error Time.Zone
    , time : Time.Posix
    , projects : WebData (List Project)
    , displayAggregated : Bool
    , apiUrl : Maybe String
    , licenseKey : Maybe String
    , showTestData : Bool
    , appStatus : AppStatus
    }
