module Pages.Home_ exposing (Model, Msg, page)

import Api.Health exposing (AppStatus(..), MissingParameter(..))
import Api.Pomodoro exposing (PomoStatsInterval(..))
import Api.Project exposing (Project)
import Components.Table
import Effect exposing (Effect)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (css)
import Html.Styled.Events exposing (onClick)
import Page exposing (Page)
import RemoteData exposing (RemoteData(..))
import Route.Path as Path
import Route.Path.Styled exposing (href)
import Route.Styled as Route exposing (Route)
import Shared
import Shared.Msg exposing (Msg(..))
import Tailwind.Theme as Theme
import Tailwind.Utilities as Tw
import Time exposing (Month(..))
import Time.Extra exposing (Interval(..))
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    {}


init : () -> ( Model, Effect Msg )
init () =
    ( {}
    , Effect.none
    )


type Msg
    = ExampleMsgReplaceMe
    | ToggleDisplayAggregatedHome


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        ExampleMsgReplaceMe ->
            ( model
            , Effect.none
            )

        ToggleDisplayAggregatedHome ->
            ( model
            , Effect.toggleDisplay
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    case shared.timezone of
        Success zone ->
            case shared.appStatus of
                AppData projects ->
                    { title = "Pomodoro.ing"
                    , body =
                        [ div []
                            [ div [ css [ Tw.mb_4 ] ]
                                [ h1
                                    [ css
                                        [ Tw.font_bold
                                        , Tw.text_2xl
                                        , Tw.mb_1
                                        , Tw.text_left
                                        ]
                                    ]
                                    [ a [ href Path.Home_ ]
                                        [ text "Pomodoro.ing" ]
                                    ]
                                , div [ css [] ]
                                    [ a [ href Path.Settings ]
                                        [ text "Settings" ]
                                    ]
                                , h1 [ css [ Tw.mb_1 ] ]
                                    [ text ("@ " ++ (shared.time |> viewDate zone))
                                    ]
                                ]
                            ]
                        , Components.Table.new
                            { aggregate = shared.displayAggregated
                            , projects = projects
                            , interval = Today
                            , zone = zone
                            , now = shared.time
                            , test = shared.showTestData
                            }
                            |> Components.Table.view
                        , Components.Table.new
                            { aggregate = shared.displayAggregated
                            , projects = projects
                            , interval = Yesterday
                            , zone = zone
                            , now = shared.time
                            , test = shared.showTestData
                            }
                            |> Components.Table.view
                        , Components.Table.new
                            { aggregate = shared.displayAggregated
                            , projects = projects
                            , interval = WeekNow
                            , zone = zone
                            , now = shared.time
                            , test = shared.showTestData
                            }
                            |> Components.Table.view
                        , Components.Table.new
                            { aggregate = shared.displayAggregated
                            , projects = projects
                            , interval = WeekLast
                            , zone = zone
                            , now = shared.time
                            , test = shared.showTestData
                            }
                            |> Components.Table.view
                        , Components.Table.new
                            { aggregate = shared.displayAggregated
                            , projects = projects
                            , interval = Days30
                            , zone = zone
                            , now = shared.time
                            , test = shared.showTestData
                            }
                            |> Components.Table.view
                        , button
                            [ css
                                [ Tw.border_2
                                , Tw.border_color Theme.black
                                , Tw.rounded
                                , Tw.mt_4
                                , Tw.px_3
                                , Tw.py_1
                                ]
                            , onClick
                                ToggleDisplayAggregatedHome
                            ]
                            [ h1
                                [ css []
                                ]
                                [ text "Toggle Project View"
                                ]
                            ]
                        ]
                    }

                InitialApp ->
                    { title = "Home"
                    , body = [ div [] [ text "Loading..." ] ]
                    }

                MissingRequiredParameters missing ->
                    { title = "Pomodoro.ing"
                    , body =
                        [ div [ css [ Tw.max_w_md ] ]
                            [ div []
                                [ div [ css [ Tw.mb_4 ] ]
                                    [ h1
                                        [ css
                                            [ Tw.font_bold
                                            , Tw.text_2xl
                                            , Tw.mb_1
                                            , Tw.text_left
                                            ]
                                        ]
                                        [ a [ href Path.Home_ ]
                                            [ text "Pomodoro.ing" ]
                                        ]
                                    , h1 [ css [ Tw.mb_1 ] ]
                                        [ text ("@ " ++ (shared.time |> viewDate zone))
                                        ]
                                    ]
                                ]
                            , case missing of
                                MissingUrl ->
                                    div []
                                        [ p []
                                            [ text "No API url set." ]
                                        , p [ css [ Tw.mt_2 ] ]
                                            [ text "Go to the "
                                            , a
                                                [ href Path.Settings
                                                , css
                                                    [ Tw.text_color Theme.blue_600
                                                    , Tw.underline
                                                    ]
                                                ]
                                                [ text "settings page" ]
                                            , text " to add it."
                                            ]
                                        ]

                                MissingKey ->
                                    div []
                                        [ p []
                                            [ text "No license key set." ]
                                        , p [ css [ Tw.mt_2 ] ]
                                            [ text "Go to the "
                                            , a
                                                [ href Path.Settings
                                                , css
                                                    [ Tw.text_color Theme.blue_600
                                                    , Tw.underline
                                                    ]
                                                ]
                                                [ text "settings page" ]
                                            , text " to add it."
                                            ]
                                        ]

                                MissingBoth ->
                                    div []
                                        [ p []
                                            [ text "No API url or license key set." ]
                                        , p [ css [ Tw.mt_2 ] ]
                                            [ text "Go to the "
                                            , a
                                                [ href Path.Settings
                                                , css
                                                    [ Tw.text_color Theme.blue_600
                                                    , Tw.underline
                                                    ]
                                                ]
                                                [ text "settings page" ]
                                            , text " to add them."
                                            ]
                                        ]
                            ]
                        ]
                    }

                ApiError ->
                    { title = "Home"
                    , body = [ div [] [ text "Api error" ] ]
                    }

                Unauthorized ->
                    { title = "Pomodoro.ing"
                    , body =
                        [ div [ css [ Tw.max_w_md ] ]
                            [ div []
                                [ div [ css [ Tw.mb_4 ] ]
                                    [ h1
                                        [ css
                                            [ Tw.font_bold
                                            , Tw.text_2xl
                                            , Tw.mb_1
                                            , Tw.text_left
                                            ]
                                        ]
                                        [ a [ href Path.Home_ ]
                                            [ text "Pomodoro.ing" ]
                                        ]
                                    , h1 [ css [ Tw.mb_1 ] ]
                                        [ text ("@ " ++ (shared.time |> viewDate zone))
                                        ]
                                    ]
                                ]
                            , div []
                                [ p []
                                    [ text "Your API is returning data, but the license key in "
                                    , a
                                        [ href Path.Settings
                                        , css
                                            [ Tw.text_color Theme.blue_600
                                            , Tw.underline
                                            ]
                                        ]
                                        [ text "settings" ]
                                    , text " doesn't match the key on your server."
                                    ]
                                , p [ css [ Tw.mt_4 ] ]
                                    [ text "Double check and make sure they're the same."
                                    ]
                                ]
                            ]
                        ]
                    }

                NoData ->
                    { title = "Pomodoro.ing"
                    , body =
                        [ div [ css [ Tw.max_w_md ] ]
                            [ div []
                                [ div [ css [ Tw.mb_4 ] ]
                                    [ h1
                                        [ css
                                            [ Tw.font_bold
                                            , Tw.text_2xl
                                            , Tw.mb_1
                                            , Tw.text_left
                                            ]
                                        ]
                                        [ a [ href Path.Home_ ]
                                            [ text "Pomodoro.ing" ]
                                        ]
                                    , h1 [ css [ Tw.mb_1 ] ]
                                        [ text ("@ " ++ (shared.time |> viewDate zone))
                                        ]
                                    ]
                                ]
                            , div []
                                [ p []
                                    [ text "Your API is working, but you haven't added any data yet."
                                    ]
                                , p [ css [ Tw.mt_4 ] ]
                                    [ text "Try typing "
                                    ]
                                ]
                            ]
                        ]
                    }

        _ ->
            { title = "Home"
            , body = [ div [] [ text "Loading..." ] ]
            }



-- viewPomoStatsByInterval :
--     String
--     -> Time.Posix
--     -> Time.Posix
--     -> List Project
--     -> Bool
--     -> Html Msg
-- viewPomoStatsByInterval heading start end projects aggregate =
--     let
--         filteredProjects =
--             projects |> filterCutoff start end
--     in
--     Components.Table.new
--         { aggregate = aggregate
--         , projects = filteredProjects
--         , interval = Today
--         , zone = zone
--         , now = now
--         }
--         |> Components.Table.view
-- div []
--     [ div [ css [ Tw.font_bold, Tw.text_xl, Tw.mb_1 ] ] [ text heading ]
--     , div [ css [ Tw.mb_3 ] ]
--         [ Components.Table.new
--             { aggregate = aggregate
--             , projects = filteredProjects
--             , interval = Today
--             }
--             |> Components.Table.view
--         ]
--     ]


filterPomodoros : Time.Posix -> Time.Posix -> Project -> Project
filterPomodoros start end project =
    let
        newPomodoros =
            List.filter
                (\pomo ->
                    ((pomo.start |> Time.posixToMillis)
                        > (start |> Time.posixToMillis)
                    )
                        && ((pomo.start |> Time.posixToMillis)
                                <= (end |> Time.posixToMillis)
                           )
                )
                project.pomodoros
    in
    { project | pomodoros = newPomodoros }


filterCutoff : Time.Posix -> Time.Posix -> List Project -> List Project
filterCutoff start end projects =
    List.filter
        (\project ->
            (project.lastTouched |> Time.posixToMillis)
                > (start |> Time.posixToMillis)
        )
        projects
        |> List.map (filterPomodoros start end)


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


viewDate1 : Time.Zone -> Time.Posix -> String
viewDate1 zone posix =
    let
        year =
            posix |> Time.toYear zone |> String.fromInt

        month =
            posix |> Time.toMonth zone |> numericMonth |> String.fromInt |> String.padLeft 2 '0'

        day =
            posix |> Time.toDay zone |> String.fromInt |> String.padLeft 2 '0'
    in
    year ++ "-" ++ month ++ "-" ++ day
