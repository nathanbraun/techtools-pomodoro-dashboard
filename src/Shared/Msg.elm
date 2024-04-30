module Shared.Msg exposing (Msg(..), Key(..))

{-| -}

import Api.Http exposing (WebData)
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
    | ToggleDisplayAggregated
    | PressedKey Key
    | SaveSettings String

type Key
    = Character Char
    | Control String
