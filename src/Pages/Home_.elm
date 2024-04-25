module Pages.Home_ exposing (page)

import Api.Pomodoro exposing (PomoStatsInterval(..))
import Api.Project exposing (Project)
import Components.Table
import Html
import Html.Styled as Html exposing (..)
import View exposing (View)


page : View msg
page =
    { title = "Homepage"
    , body = [ text "Hello, world!" ]
    }
