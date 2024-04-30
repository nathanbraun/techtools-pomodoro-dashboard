module Shared exposing
    ( Flags, decoder
    , Model, Msg
    , init, update, subscriptions
    )

{-|

@docs Flags, decoder
@docs Model, Msg
@docs init, update, subscriptions

-}

import Api.Project as Project exposing (Project)
import Browser.Events
import Effect exposing (Effect)
import Graphql.Http
import Json.Decode
import RemoteData exposing (RemoteData(..))
import Route exposing (Route)
import Route.Path
import Shared.Model
import Shared.Msg exposing (Key(..))
import Task exposing (Task)
import Time
import TimeZone



-- FLAGS


type alias Flags =
    { apiUrl : String }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map Flags
        (Json.Decode.field "apiUrl" Json.Decode.string)



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    let
        apiUrl =
            flagsResult
                |> Result.map .apiUrl
                |> Result.toMaybe
    in
    ( { timezone = Loading
      , time = Time.millisToPosix 0
      , projects = NotAsked
      , displayAggregated = True
      , apiUrl = apiUrl
      }
    , Effect.batch
        [ Effect.sendCmd
            (TimeZone.getZone
                |> Task.attempt
                    (RemoteData.fromResult >> Shared.Msg.ReceiveTimeZone)
            )
        , Effect.sendCmd (Task.perform Shared.Msg.GetTime Time.now)
        , case apiUrl of
            Just url ->
                Effect.sendCmd
                    (Project.queryProjects
                        |> Graphql.Http.queryRequest ("https://" ++ url)
                        |> Graphql.Http.send
                            (RemoteData.fromResult
                                >> Shared.Msg.GotProjects
                            )
                    )

            Nothing ->
                Effect.none
        ]
    )



-- UPDATE


type alias Msg =
    Shared.Msg.Msg


update : Route () -> Msg -> Model -> ( Model, Effect Msg )
update route msg model =
    case msg of
        Shared.Msg.NoOp ->
            ( model
            , Effect.none
            )

        Shared.Msg.GetTime time ->
            ( { model | time = time }
            , Effect.none
            )

        Shared.Msg.ReceiveTimeZone response ->
            ( { model | timezone = response |> RemoteData.map Tuple.second }
            , Effect.none
            )

        Shared.Msg.GotProjects response ->
            ( { model | projects = response }
            , Effect.none
            )

        Shared.Msg.ToggleDisplayAggregated ->
            ( { model | displayAggregated = not model.displayAggregated }
            , Effect.none
            )

        Shared.Msg.PressedKey (Character 'n') ->
            ( { model | displayAggregated = not model.displayAggregated }
            , Effect.none
            )

        Shared.Msg.PressedKey _ ->
            ( model
            , Effect.none
            )

        Shared.Msg.SaveSettings url ->
            ( { model | apiUrl = Just url }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Route () -> Model -> Sub Msg
subscriptions route model =
    Browser.Events.onKeyDown keyDecoder


keyDecoder : Json.Decode.Decoder Shared.Msg.Msg
keyDecoder =
    Json.Decode.map Shared.Msg.PressedKey (Json.Decode.field "key" (Json.Decode.string |> Json.Decode.andThen toKeyDecoder))


toKeyDecoder : String -> Json.Decode.Decoder Shared.Msg.Key
toKeyDecoder string =
    case String.uncons string of
        Just ( char, "" ) ->
            Json.Decode.succeed (Character char)

        _ ->
            Json.Decode.succeed (Control string)
