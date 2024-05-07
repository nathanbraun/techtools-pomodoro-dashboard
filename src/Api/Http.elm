module Api.Http exposing (WebData)

import Graphql.Http
import RemoteData exposing (RemoteData)


type alias WebData a =
    RemoteData (Graphql.Http.Error a) a


