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

import Api.Health as Health exposing (AppStatus(..), MissingParameter(..))
import Api.Project as Project
import Browser.Events
import Effect exposing (Effect)
import Graphql.Http
import Interop exposing (OutgoingData(..))
import Json.Decode
import RemoteData exposing (RemoteData(..))
import Route exposing (Route)
import Shared.Model
import Shared.Msg exposing (Key(..))
import Task
import Time
import TimeZone



-- FLAGS


type alias Flags =
    { apiUrl : Maybe String
    , passkey : Maybe String
    , testDataFlag : Bool
    }


decoder : Json.Decode.Decoder Flags
decoder =
    Json.Decode.map3 Flags
        (Json.Decode.field "apiUrl" (Json.Decode.maybe Json.Decode.string))
        (Json.Decode.field "passkey" (Json.Decode.maybe Json.Decode.string))
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
    case ( flags.apiUrl, flags.passkey ) of
        ( Just url, Just key ) ->
            ( { timezone = Time.utc
              , time = Time.millisToPosix 0
              , displayAggregated = True
              , apiUrl = Just url
              , passkey = Just key
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
                                >> Shared.Msg.GotHealth url
                            )
                    )
                ]
            )

        ( Nothing, Just key ) ->
            ( { timezone = Time.utc
              , time = Time.millisToPosix 0
              , displayAggregated = True
              , apiUrl = flags.apiUrl
              , passkey = flags.passkey
              , showTestData = flags.testDataFlag
              , appStatus = MissingRequiredParameters MissingUrl
              }
            , Effect.batch
                [ Effect.sendCmd
                    (TimeZone.getZone
                        |> Task.attempt
                            (RemoteData.fromResult >> Shared.Msg.ReceiveTimeZone)
                    )
                , Effect.sendCmd (Task.perform Shared.Msg.GetTime Time.now)
                ]
            )

        ( Just url, Nothing ) ->
            ( { timezone = Time.utc
              , time = Time.millisToPosix 0
              , displayAggregated = True
              , apiUrl = flags.apiUrl
              , passkey = flags.passkey
              , showTestData = flags.testDataFlag
              , appStatus = MissingRequiredParameters MissingKey
              }
            , Effect.batch
                [ Effect.sendCmd
                    (TimeZone.getZone
                        |> Task.attempt
                            (RemoteData.fromResult >> Shared.Msg.ReceiveTimeZone)
                    )
                , Effect.sendCmd (Task.perform Shared.Msg.GetTime Time.now)
                ]
            )

        ( Nothing, Nothing ) ->
            ( { timezone = Time.utc
              , time = Time.millisToPosix 0
              , displayAggregated = True
              , apiUrl = flags.apiUrl
              , passkey = flags.passkey
              , showTestData = flags.testDataFlag
              , appStatus = MissingRequiredParameters MissingBoth
              }
            , Effect.batch
                [ Effect.sendCmd
                    (TimeZone.getZone
                        |> Task.attempt
                            (RemoteData.fromResult >> Shared.Msg.ReceiveTimeZone)
                    )
                , Effect.sendCmd (Task.perform Shared.Msg.GetTime Time.now)
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

        Shared.Msg.ReceiveTimeZone (Success response) ->
            ( { model | timezone = response |> Tuple.second }
            , Effect.none
            )

        Shared.Msg.ReceiveTimeZone _ ->
            ( { model | timezone = Time.utc }
            , Effect.none
            )

        Shared.Msg.GotProjects (Success projects) ->
            ( { model | appStatus = AppData projects }
            , Effect.none
            )

        Shared.Msg.GotProjects _ ->
            ( { model | appStatus = ApiError }
            , Effect.none
            )

        Shared.Msg.GotHealth url healthResponse ->
            case healthResponse of
                Success response ->
                    case ( response.authorized, response.anyPomos ) of
                        ( True, True ) ->
                            ( model
                            , Effect.sendCmd
                                (Project.queryProjects
                                    |> Graphql.Http.queryRequest
                                        ("https://"
                                            ++ url
                                        )
                                    |> Graphql.Http.send
                                        (RemoteData.fromResult
                                            >> Shared.Msg.GotProjects
                                        )
                                )
                            )

                        ( False, _ ) ->
                            ( { model | appStatus = Unauthorized }, Effect.none )

                        ( True, False ) ->
                            ( { model | appStatus = NoData }, Effect.none )

                _ ->
                    ( { model | appStatus = ApiError }, Effect.none )

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
            case ( url, key ) of
                ( Just url_, Just key_ ) ->
                    ( { model
                        | apiUrl = url
                        , passkey = key
                        , showTestData =
                            test
                      }
                    , Effect.sendCmd
                        (Health.queryHealth key_
                            |> Graphql.Http.queryRequest ("https://" ++ url_)
                            |> Graphql.Http.send
                                (RemoteData.fromResult
                                    >> Shared.Msg.GotHealth url_
                                )
                        )
                    )

                ( Just _, Nothing ) ->
                    ( { model
                        | apiUrl = url
                        , passkey = key
                        , showTestData = test
                        , appStatus = MissingRequiredParameters MissingKey
                      }
                    , Effect.none
                    )

                ( Nothing, Just _ ) ->
                    ( { model
                        | apiUrl = url
                        , passkey = key
                        , showTestData = test
                        , appStatus = MissingRequiredParameters MissingUrl
                      }
                    , Effect.none
                    )

                ( Nothing, Nothing ) ->
                    ( { model
                        | apiUrl = url
                        , passkey = key
                        , showTestData = test
                        , appStatus = MissingRequiredParameters MissingBoth
                      }
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
