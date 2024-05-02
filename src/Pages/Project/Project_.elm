module Pages.Project.Project_ exposing (Model, Msg, page)

import Api.Http exposing (WebData)
import Api.Pomodoro exposing (PomoStatsInterval(..), Pomodoro)
import Api.Project as Project exposing (Project)
import Components.Table
import Effect exposing (Effect)
import Graphql.Http
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (css)
import Page exposing (Page)
import RemoteData exposing (RemoteData(..))
import Round
import Route exposing (Route)
import Shared
import Tailwind.Utilities as Tw
import Time exposing (Month(..))
import View exposing (View)


page : Shared.Model -> Route { project : String } -> Page Model Msg
page shared route =
    Page.new
        { init = init shared route.params.project
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    { project : WebData Project
    }


init : Shared.Model -> String -> () -> ( Model, Effect Msg )
init shared project _ =
    ( { project = NotAsked }
    , case shared.apiUrl of
        Just url ->
            Effect.sendCmd
                (Project.queryProject project
                    |> Graphql.Http.queryRequest ("https://" ++ url)
                    |> Graphql.Http.send (RemoteData.fromResult >> GotProject)
                )

        Nothing ->
            Effect.none
    )



-- UPDATE


type Msg
    = NoOp
    | GotProject (WebData Project)


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Effect.none
            )

        GotProject response ->
            ( { model | project = response }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    case ( shared.timezone, model.project ) of
        ( Success zone, Success project ) ->
            { title = "Project"
            , body = [ viewProject zone project ]
            }

        ( Failure _, _ ) ->
            { title = "Error"
            , body = [ div [] [ text "Error" ] ]
            }

        ( _, Failure _ ) ->
            { title = "Error"
            , body = [ div [] [ text "Error" ] ]
            }

        _ ->
            { title = "Error"
            , body = [ div [] [ text "Loading" ] ]
            }


viewProject : Time.Zone -> Project -> Html Msg
viewProject timezone project =
    let
        now =
            project.asOf
    in
    div [ css [ Tw.max_w_xl ] ]
        [ div [ css [ Tw.mb_3, Tw.font_bold ] ]
            [ h1 [ css [ Tw.mb_1, Tw.text_2xl ] ]
                [ text project.name ]
            , h1 [ css [ Tw.mb_1 ] ]
                [ text ("@ " ++ (project.asOf |> viewDate timezone))
                ]
            ]
        , Components.Table.new
            { aggregate = True
            , projects = [ project ]
            , interval = Today
            , zone = timezone
            , now = now
            }
            |> Components.Table.view
        , Components.Table.new
            { aggregate = True
            , projects = [ project ]
            , interval = Yesterday
            , zone = timezone
            , now = now
            }
            |> Components.Table.view
        , Components.Table.new
            { aggregate = True
            , projects = [ project ]
            , interval = WeekNow
            , zone = timezone
            , now = now
            }
            |> Components.Table.view
        , Components.Table.new
            { aggregate = True
            , projects = [ project ]
            , interval = WeekLast
            , zone = timezone
            , now = now
            }
            |> Components.Table.view
        , Components.Table.new
            { aggregate = True
            , projects = [ project ]
            , interval = Days30
            , zone = timezone
            , now = now
            }
            |> Components.Table.view
        , Components.Table.new
            { aggregate = True
            , projects = [ project ]
            , interval = All
            , zone = timezone
            , now = now
            }
            |> Components.Table.view
        , div [ css [ Tw.mt_5 ] ]
            [ div [ css [ Tw.font_bold, Tw.text_2xl, Tw.mb_1 ] ]
                [ text "Last 10 Pomodoros"
                ]
            , div []
                (List.map (viewPomodoro timezone) (List.take 10 project.pomodoros))
            ]

        -- , div [] (List.map (viewPomodoro timezone) project.pomodoros)
        ]


viewDate : Time.Zone -> Time.Posix -> String
viewDate zone posix =
    let
        year =
            posix |> Time.toYear zone |> String.fromInt

        month =
            posix |> Time.toMonth zone |> numericMonth |> String.fromInt |> String.padLeft 2 '0'

        day =
            posix |> Time.toDay zone |> String.fromInt |> String.padLeft 2 '0'

        hour =
            posix |> Time.toHour zone |> String.fromInt |> String.padLeft 2 '0'

        minute =
            posix |> Time.toMinute zone |> String.fromInt |> String.padLeft 2 '0'
    in
    year ++ "-" ++ month ++ "-" ++ day ++ " " ++ hour ++ ":" ++ minute


numericMonth : Time.Month -> Int
numericMonth month =
    case month of
        Jan ->
            1

        Feb ->
            2

        Mar ->
            3

        Apr ->
            4

        May ->
            5

        Jun ->
            6

        Jul ->
            7

        Aug ->
            8

        Sep ->
            9

        Oct ->
            10

        Nov ->
            11

        Dec ->
            12


viewPomodoro : Time.Zone -> Pomodoro -> Html Msg
viewPomodoro timezone pomo =
    div [ css [ Tw.w_64, Tw.flex ] ]
        [ div [ css [ Tw.flex_1 ] ] [ text (pomo.start |> viewDate timezone) ]
        , div [ css [ Tw.ml_auto ] ] [ text (pomo.duration |> durationToHuman) ]
        ]


durationToHuman : Int -> String
durationToHuman seconds =
    let
        ( unit, denom ) =
            if seconds < 60 then
                ( "s", 1.0 )

            else if seconds < 3600 then
                ( "m", 60.0 )

            else
                ( "h", 3600.0 )
    in
    (seconds |> toFloat |> (\x -> x / denom) |> Round.round 0) ++ unit
