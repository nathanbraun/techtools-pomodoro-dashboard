module Route.Path.Styled exposing (href)

import Html.Styled as Html
import Html.Styled.Attributes as Attributes
import Route.Path exposing (Path)


href : Path -> Html.Attribute msg
href path =
    Attributes.href (Route.Path.toString path)

