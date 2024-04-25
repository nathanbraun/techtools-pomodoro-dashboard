module Api.Project exposing
    ( Project
    , ProjectName
    , queryProject
    , queryProjectName
    , queryProjects
    , filterCutoff
    )

import Api.Pomodoro exposing (Pomodoro)
import Graphql.Operation exposing (RootQuery)
import Graphql.OptionalArgument as OptionalArgument exposing (OptionalArgument(..))
import Graphql.SelectionSet as SelectionSet
    exposing
        ( SelectionSet
        , hardcoded
        , with
        )
import Pomo.Object
import Pomo.Object.Project as Project
import Pomo.Query as Query
import Time


type alias ProjectName =
    { projectId : Int
    , name : String
    }


type alias Project =
    { projectId : Int
    , name : String
    , totalDuration : Int
    , nPomos : Int
    , pomodoros : List Pomodoro
    , asOf : Time.Posix
    , lastTouched : Time.Posix
    }


queryProjects : SelectionSet (List Project) RootQuery
queryProjects =
    Query.projects
        (\optionals ->
            { optionals
                | start_time = OptionalArgument.fromMaybe Nothing
                , end_time = OptionalArgument.fromMaybe Nothing
            }
        )
        projectSelectionSet


query : SelectionSet a Pomo.Object.Project -> String -> SelectionSet a RootQuery
query selectionSet project =
    Query.project
        (\optionals ->
            { optionals
                | start_time = OptionalArgument.fromMaybe Nothing
                , end_time = OptionalArgument.fromMaybe Nothing
            }
        )
        { project = project }
        selectionSet


queryProject : String -> SelectionSet Project RootQuery
queryProject project =
    query projectSelectionSet project


queryProjectName : String -> SelectionSet ProjectName RootQuery
queryProjectName project =
    query projectNameSelectionSet project


projectSelectionSet : SelectionSet Project Pomo.Object.Project
projectSelectionSet =
    SelectionSet.map7 Project
        Project.id
        Project.name
        Project.total_duration
        Project.n_pomodoros
        (Project.pomodoros Api.Pomodoro.selectionSet)
        (Project.as_of |> SelectionSet.mapOrFail stringToPosix)
        (Project.last_touched |> SelectionSet.map ((*) 1000 >> Time.millisToPosix))

projectNameSelectionSet : SelectionSet ProjectName Pomo.Object.Project
projectNameSelectionSet =
    SelectionSet.map2 ProjectName
        Project.id
        Project.name


stringToPosix : String -> Result String Time.Posix
stringToPosix timeString =
    case String.toInt timeString of
        Just time ->
            Ok (Time.millisToPosix time)

        Nothing ->
            Err "Invalid time string"

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

