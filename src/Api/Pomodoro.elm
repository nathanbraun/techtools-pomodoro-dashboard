module Api.Pomodoro exposing
    ( PomoStatsInterval(..)
    , Pomodoro
    , PomodoroStats
    , pomodoroStats
    , selectionSet
    , statsStartEnd
    )

import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)
import Pomo.Object
import Pomo.Object.Pomodoro as Pomodoro
import Time
import Time.Extra exposing (Interval(..))


type alias Pomodoro =
    { id : Int
    , duration : Int
    , start : Time.Posix
    }


type PomoStatsInterval
    = Today
    | Yesterday
    | WeekNow
    | WeekLast
    | Days30
    | Date


statsStartEnd :
    PomoStatsInterval
    -> Time.Zone
    -> Time.Posix
    -> { start : Time.Posix, end : Time.Posix, heading : String }
statsStartEnd interval zone now =
    case interval of
        Today ->
            { start = Time.Extra.floor Day zone now
            , end = now
            , heading = "Today"
            }

        Date ->
            { start =
                Time.Extra.floor Day
                    zone
                    now
            , end =
                Time.Extra.floor Day
                    zone
                    now
                    |> Time.Extra.add Day 1 zone
            , heading = ""
            }

        Yesterday ->
            { start =
                Time.Extra.floor Day zone now
                    |> Time.Extra.add Day -1 zone
            , end = Time.Extra.floor Day zone now
            , heading = "Yesterday"
            }

        WeekNow ->
            { start = Time.Extra.floor Monday zone now
            , end = now
            , heading = "This Week"
            }

        WeekLast ->
            { start =
                Time.Extra.floor Monday zone now
                    |> Time.Extra.add Week -1 zone
            , end = Time.Extra.floor Monday zone now
            , heading = "Last Week"
            }

        Days30 ->
            { start =
                Time.Extra.add Day
                    -30
                    zone
                    now
            , end = now
            , heading = "30 Days"
            }


type alias PomodoroStats =
    { nPomos : Int
    , totalDuration : Int
    }


selectionSet : SelectionSet Pomodoro Pomo.Object.Pomodoro
selectionSet =
    SelectionSet.map3 Pomodoro
        Pomodoro.id
        Pomodoro.duration
        (Pomodoro.start |> SelectionSet.map ((*) 1000 >> Time.millisToPosix))


pomodoroStats : List Pomodoro -> PomodoroStats
pomodoroStats pomodoros =
    PomodoroStats (List.length pomodoros)
        (List.foldl
            (\pomo acc ->
                pomo.duration + acc
            )
            0
            pomodoros
        )
