module Api.Health exposing (AppStatus(..), Health, MissingParameter(..), queryHealth)

import Api.Project exposing (Project)
import Graphql.Operation exposing (RootQuery)
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Pomo.Object.Health as Health
import Pomo.Query as Query


type MissingParameter
    = MissingUrl
    | MissingKey
    | MissingBoth


type AppStatus
    = InitialApp
    | MissingRequiredParameters MissingParameter
    | ApiError
    | Unauthorized
    | NoData
    | AppData (List Project)


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
