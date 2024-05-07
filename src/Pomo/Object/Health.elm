-- Do not manually edit this file, it was auto-generated by dillonkearns/elm-graphql
-- https://github.com/dillonkearns/elm-graphql


module Pomo.Object.Health exposing (..)

import Graphql.Internal.Builder.Argument as Argument exposing (Argument)
import Graphql.Internal.Builder.Object as Object
import Graphql.Internal.Encode as Encode exposing (Value)
import Graphql.Operation exposing (RootMutation, RootQuery, RootSubscription)
import Graphql.OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet exposing (SelectionSet)
import Json.Decode as Decode
import Pomo.InputObject
import Pomo.Interface
import Pomo.Object
import Pomo.Scalar
import Pomo.ScalarCodecs
import Pomo.Union


authorized : SelectionSet Bool Pomo.Object.Health
authorized =
    Object.selectionForField "Bool" "authorized" [] Decode.bool


any_pomos : SelectionSet Bool Pomo.Object.Health
any_pomos =
    Object.selectionForField "Bool" "any_pomos" [] Decode.bool
