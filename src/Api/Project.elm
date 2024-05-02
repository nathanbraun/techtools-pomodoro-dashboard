module Api.Project exposing
    ( Project
    , ProjectName
    , filterCutoff
    , queryProject
    , queryProjectName
    , queryProjects
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


filterPomodoros : Bool -> Time.Posix -> Time.Posix -> Project -> Project
filterPomodoros test start end project =
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

        newPomodoros2 =
            if test then
                newPomodoros

            else
                List.filter (\pomo -> not pomo.test) newPomodoros
    in
    { project | pomodoros = newPomodoros2 }


filterCutoff : Bool -> Time.Posix -> Time.Posix -> List Project -> List Project
filterCutoff test start end projects =
    List.filter
        (\project ->
            (project.lastTouched |> Time.posixToMillis)
                > (start |> Time.posixToMillis)
        )
        projects
        |> List.map (filterPomodoros test start end)
