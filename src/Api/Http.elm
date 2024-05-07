module Api.Http exposing (Health, WebData, queryHealth)

import Graphql.Http
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Pomo.Object.Health as Health
import Pomo.Query as Query
import RemoteData exposing (RemoteData)


type alias WebData a =
    RemoteData (Graphql.Http.Error a) a


type alias Health =
    { authorized : Bool
    , anyPomos : Bool
    }


queryHealth : String -> SelectionSet Health RootQuery
queryHealth key =
    Query.health { key = key }
        (SelectionSet.map2 Health
            Health.authorized
            Health.any_pomos
        )
