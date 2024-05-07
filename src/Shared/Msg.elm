module Shared.Msg exposing (Key(..), Msg(..))

{-| -}

import Api.Http exposing (Health, WebData)
import Api.Project as Project exposing (Project)
import RemoteData exposing (RemoteData)
import Time
import TimeZone


{-| Normally, this value would live in "Shared.elm"
but that would lead to a circular dependency import cycle.

For that reason, both `Shared.Model` and `Shared.Msg` are in their
own file, so they can be imported by `Effect.elm`

-}
type Msg
    = NoOp
    | ReceiveTimeZone (RemoteData TimeZone.Error ( String, Time.Zone ))
    | GetTime Time.Posix
    | GotProjects (WebData (List Project))
    | GotHealth (WebData Health)
    | ToggleDisplayAggregated
    | PressedKey Key
    | SaveSettings (Maybe String) (Maybe String) Bool


type Key
    = Character Char
    | Control String
