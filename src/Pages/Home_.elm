module Pages.Home_ exposing (Model, Msg, page)

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
import Tailwind.Theme as Tw
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
    case ( shared.timezone, shared.projects ) of
        ( Success zone, Success projects ) ->
            { title = "Pomodoros"
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
                                [ text "Pomodoros" ]
                            ]
                        , div [ css [] ]
                            [ a
                                [ href
                                    (Path.Day_Date_
                                        { date = shared.time |> viewDate1 zone
                                        }
                                    )
                                ]
                                [ text "Day" ]
                            , span [] [ text " | " ]
                            , button [ onClick ToggleDisplayAggregatedHome ]
                                [ h1
                                    [ css []
                                    ]
                                    [ text "Project"
                                    ]
                                ]
                            , span [] [ text " | " ]
                            , a [ href Path.Settings ]
                                [ text "⚙" ]
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
                    }
                    |> Components.Table.view
                , Components.Table.new
                    { aggregate = shared.displayAggregated
                    , projects = projects
                    , interval = Yesterday
                    , zone = zone
                    , now = shared.time
                    }
                    |> Components.Table.view
                , Components.Table.new
                    { aggregate = shared.displayAggregated
                    , projects = projects
                    , interval = WeekNow
                    , zone = zone
                    , now = shared.time
                    }
                    |> Components.Table.view
                , Components.Table.new
                    { aggregate = shared.displayAggregated
                    , projects = projects
                    , interval = WeekLast
                    , zone = zone
                    , now = shared.time
                    }
                    |> Components.Table.view
                , Components.Table.new
                    { aggregate = shared.displayAggregated
                    , projects = projects
                    , interval = Days30
                    , zone = zone
                    , now = shared.time
                    }
                    |> Components.Table.view
                ]
            }

        ( _, Failure _ ) ->
            { title = "Home"
            , body = [ div [] [ text "Failed to load projects..." ] ]
            }

        ( Failure _, _ ) ->
            { title = "Home"
            , body = [ div [] [ text "Failed to get timezone..." ] ]
            }

        ( _, _ ) ->
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
