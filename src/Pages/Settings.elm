module Pages.Settings exposing (Model, Msg, page)

import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr exposing (css)
import Html.Styled.Events as Events
import Page exposing (Page)
import Route exposing (Route)
import Shared
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Theme
import Tailwind.Utilities as Tw
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init shared
        , update = update
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    { inputUrl : Maybe String }


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared () =
    ( { inputUrl = shared.apiUrl }
    , Effect.none
    )



-- UPDATE


type Msg
    = UpdateUrl String


update : Msg -> Model -> ( Model, Effect Msg )
update msg model =
    case msg of
        UpdateUrl url ->
            ( { model | inputUrl = Just url }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Settings"
    , body =
        [ case shared.apiUrl of
            Just _ ->
                div []
                    [ inputView model.inputUrl
                    ]

            Nothing ->
                div []
                    [ div [] [ text "You haven't entered your API url yet." ]
                    , inputView model.inputUrl
                    ]
        ]
    }


inputView : Maybe String -> Html Msg
inputView url =
    form []
        [ div [ css [ Tw.max_w_md ] ]
            [ div []
                [ label
                    [ Attr.for "api-url"
                    , css
                        [ Tw.block
                        , Tw.text_sm
                        , Tw.font_medium
                        , Tw.leading_6
                        , Tw.text_color Theme.gray_900
                        ]
                    ]
                    [ text "API Url" ]
                , div
                    [ css
                        [ Tw.mt_2
                        ]
                    ]
                    [ div
                        [ css
                            [ Tw.flex
                            , Tw.rounded_md
                            , Tw.shadow_sm
                            , Tw.ring_1
                            , Tw.ring_inset
                            , Tw.ring_color Theme.gray_300
                            , Css.focus
                                [ Tw.ring_2
                                , Tw.ring_inset
                                , Tw.ring_color Theme.indigo_600
                                ]
                            , Bp.sm
                                [ Tw.max_w_md
                                ]
                            ]
                        ]
                        [ span
                            [ css
                                [ Tw.flex
                                , Tw.select_none
                                , Tw.items_center
                                , Tw.pl_3
                                , Tw.text_color Theme.gray_500
                                , Bp.sm
                                    [ Tw.text_sm
                                    ]
                                ]
                            ]
                            [ text "https://" ]
                        , input
                            [ Attr.type_ "text"
                            , Attr.name "api-url"
                            , Attr.id "api-url"
                            , Events.onInput UpdateUrl
                            , css
                                [ Tw.block
                                , Tw.flex_1
                                , Tw.border_0
                                , Tw.bg_color Theme.transparent
                                , Tw.py_1_dot_5
                                , Tw.pl_1
                                , Tw.text_color Theme.gray_900
                                , Tw.placeholder_color Theme.gray_400
                                , Css.focus
                                    [ Tw.ring_0
                                    ]
                                , Bp.sm
                                    [ Tw.text_sm
                                    , Tw.leading_6
                                    ]
                                ]
                            , case url of
                                Just url_ ->
                                    Attr.value url_

                                Nothing ->
                                    Attr.placeholder "api.example.com"
                            ]
                            []
                        ]
                    ]
                ]
            , saveButton
            ]
        ]


saveButton : Html Msg
saveButton =
    div
        [ css
            [ Tw.mt_6
            , Tw.flex
            , Tw.items_center
            , Tw.justify_end
            , Tw.gap_x_6
            ]
        ]
        [ button
            [ Attr.type_ "button"
            , css
                [ Tw.text_sm
                , Tw.font_semibold
                , Tw.leading_6
                , Tw.text_color Theme.gray_900
                ]
            ]
            [ text "Cancel" ]
        , button
            [ Attr.type_ "submit"
            , css
                [ Tw.rounded_md
                , Tw.bg_color Theme.indigo_600
                , Tw.px_3
                , Tw.py_2
                , Tw.text_sm
                , Tw.font_semibold
                , Tw.text_color Theme.white
                , Tw.shadow_sm
                , Css.focus
                    [ Tw.outline
                    , Tw.outline_2
                    , Tw.outline_offset_2
                    , Tw.outline_color Theme.indigo_600
                    ]
                , Css.hover
                    [ Tw.bg_color Theme.indigo_500
                    ]
                ]
            ]
            [ text "Save" ]
        ]
