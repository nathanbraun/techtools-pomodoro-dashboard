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

import Api.Health as Health exposing (AppStatus(..))
import Api.Project as Project
import Browser.Events
import Effect exposing (Effect)
import Graphql.Http
import Json.Decode
import RemoteData exposing (RemoteData(..))
import Route exposing (Route)
import Route.Path as Path
import Shared.Model
import Shared.Msg exposing (Key(..))
import Task
import Time
import TimeZone



-- FLAGS


type alias Flags =
    { apiUrl : Maybe String
    , licenseKey : Maybe String
    , testDataFlag : Bool
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map3 Flags
        (Json.Decode.field "apiUrl" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "licenseKey" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "testDataFlag" Json.Decode.bool)



-- INIT


type alias Model =
    Shared.Model.Model


init : Result Json.Decode.Error Flags -> Route () -> ( Model, Effect Msg )
init flagsResult route =
    let
        flags =
            flagsResult
                |> Result.withDefault (Flags Nothing Nothing True)
    in
    case ( flags.apiUrl, flags.licenseKey ) of
        ( Just url, Just key ) ->
            ( { timezone = Loading
              , time = Time.millisToPosix 0
              , projects = NotAsked
              , displayAggregated = True
              , apiUrl = Just url
              , licenseKey = Just key
              , showTestData = flags.testDataFlag
              , appStatus = InitialApp
              }
            , Effect.batch
                [ Effect.sendCmd
                    (TimeZone.getZone
                        |> Task.attempt
                            (RemoteData.fromResult >> Shared.Msg.ReceiveTimeZone)
                    )
                , Effect.sendCmd (Task.perform Shared.Msg.GetTime Time.now)
                , Effect.sendCmd
                    (Health.queryHealth key
                        |> Graphql.Http.queryRequest ("https://" ++ url)
                        |> Graphql.Http.send
                            (RemoteData.fromResult
                                >> Shared.Msg.GotHealth
                            )
                    )
                ]
            )

        ( _, _ ) ->
            ( { timezone = Loading
              , time = Time.millisToPosix 0
              , projects = NotAsked
              , displayAggregated = True
              , apiUrl = flags.apiUrl
              , licenseKey = flags.licenseKey
              , showTestData = flags.testDataFlag
              , appStatus = MissingRequiredParameters
              }
            , Effect.batch
                [ Effect.sendCmd
                    (TimeZone.getZone
                        |> Task.attempt
                            (RemoteData.fromResult >> Shared.Msg.ReceiveTimeZone)
                    )
                , Effect.sendCmd (Task.perform Shared.Msg.GetTime Time.now)
                , Effect.pushRoutePath Path.Settings
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

        Shared.Msg.GotHealth response ->
            ( model
            , case model.apiUrl of
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
                    Effect.pushRoutePath Path.Settings
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

        Shared.Msg.SaveSettings url key test ->
            ( { model | apiUrl = url, licenseKey = key, showTestData = test }
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
