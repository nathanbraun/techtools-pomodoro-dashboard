module Components.Table exposing (new, view)

import Api.Pomodoro exposing (PomoStatsInterval(..), pomodoroStats)
import Api.Project exposing (Project, filterCutoff)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes exposing (css)
import Round
import Route.Path as Path
import Route.Path.Styled exposing (href)
import Tailwind.Theme as Tw
import Tailwind.Utilities as Tw
import Time


type PomoStats msg
    = Settings
        { aggregate : Bool
        , projects : List Project
        , interval : PomoStatsInterval
        , now : Time.Posix
        , zone : Time.Zone
        , heading : String
        }


new :
    { projects : List Project
    , aggregate : Bool
    , interval : PomoStatsInterval
    , now : Time.Posix
    , zone : Time.Zone
    }
    -> PomoStats msg
new props =
    let
        bounds =
            Api.Pomodoro.statsStartEnd props.interval props.zone props.now

        filteredProjects =
            props.projects |> filterCutoff bounds.start bounds.end
    in
    Settings
        { aggregate = props.aggregate
        , projects = filteredProjects
        , interval = props.interval
        , now = props.now
        , zone = props.zone
        , heading = bounds.heading
        }


view : PomoStats msg -> Html msg
view (Settings settings) =
    div []
        [ div [ css [ Tw.font_bold, Tw.text_xl, Tw.mb_1 ] ]
            [ text settings.heading
            ]
        , div [ css [ Tw.mb_3 ] ]
            [ if List.isEmpty settings.projects then
                span [ css [ Tw.whitespace_pre ] ] [ text " — " ]

              else if settings.aggregate then
                let
                    allEmpty =
                        List.all (\project -> List.isEmpty project.pomodoros)
                            settings.projects
                in
                if allEmpty then
                    span [ css [ Tw.whitespace_pre ] ] [ text " — " ]

                else
                    let
                        stats =
                            settings.projects
                                |> List.map .pomodoros
                                |> List.concat
                                |> pomodoroStats
                    in
                    div [ css [ Tw.max_w_md ] ]
                        [ p [ css [ Tw.ml_auto, Tw.whitespace_pre ] ]
                            [ text
                                (stats.nPomos
                                    |> String.fromInt
                                    |> String.padLeft 2 ' '
                                )
                            , text " for "
                            , text
                                ((stats.totalDuration |> toFloat)
                                    |> (\x -> x / (60 * 60) |> Round.round 2)
                                    |> String.padLeft 5 ' '
                                )
                            , text " total"
                            ]
                        ]

              else
                div []
                    (List.map viewProject settings.projects)
            ]
        ]


viewProject : Project -> Html msg
viewProject project =
    let
        stats =
            pomodoroStats project.pomodoros
    in
    if List.isEmpty project.pomodoros then
        div [ css [ Tw.whitespace_pre ] ] [ text " — " ]

    else
        div [ css [ Tw.flex, Tw.max_w_md ] ]
            [ a
                [ css [ Tw.underline, Tw.text_color Tw.blue_500, Tw.flex_1 ]
                , href
                    (Path.Project_Project_
                        { project =
                            project.name
                        }
                    )
                ]
                [ text project.name ]
            , div []
                [ p [ css [ Tw.ml_auto, Tw.whitespace_pre ] ]
                    [ text
                        (stats.nPomos
                            |> String.fromInt
                            |> String.padLeft 2 ' '
                        )
                    , text " for "
                    , text
                        ((stats.totalDuration |> toFloat)
                            |> (\x -> x / (60 * 60) |> Round.round 2)
                            |> String.padLeft 5 ' '
                        )
                    , text
                        " total"
                    ]
                ]
            ]
