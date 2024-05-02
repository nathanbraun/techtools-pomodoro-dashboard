module Pages.Settings exposing (Model, Msg, page)

import Browser.Events
import Css
import Effect exposing (Effect)
import Html.Styled as Html exposing (..)
import Html.Styled.Attributes as Attr exposing (css)
import Html.Styled.Events as Events
import Json.Decode
import Page exposing (Page)
import RemoteData exposing (RemoteData(..))
import Route exposing (Route)
import Route.Path as Path
import Route.Path.Styled exposing (href)
import Shared
import Tailwind.Breakpoints as Bp
import Tailwind.Theme as Theme
import Tailwind.Utilities as Tw
import View exposing (View)


page : Shared.Model -> Route () -> Page Model Msg
page shared route =
    Page.new
        { init = init shared
        , update = update shared
        , subscriptions = subscriptions
        , view = view shared
        }



-- INIT


type alias Model =
    { changed : Bool
    , inputUrl : Maybe String
    , inputKey : Maybe String
    , localTest : Bool
    }


init : Shared.Model -> () -> ( Model, Effect Msg )
init shared () =
    ( { changed = False
      , inputUrl = shared.apiUrl
      , inputKey = shared.licenseKey
      , localTest = shared.showTestData
      }
    , Effect.none
    )



-- UPDATE


type Msg
    = UpdateUrl String
    | UpdateLicense String
    | ClickCancel
    | ClickSave (Maybe String)
    | PressedKey Key
    | ToggleTest


type Key
    = Character Char
    | Control String


update : Shared.Model -> Msg -> Model -> ( Model, Effect Msg )
update shared msg model =
    case msg of
        UpdateUrl url ->
            ( { model | inputUrl = Just url, changed = True }
            , Effect.none
            )

        UpdateLicense key ->
            let
                newKey =
                    if key == "" then
                        Nothing

                    else
                        Just key
            in
            ( { model | inputKey = newKey, changed = True }
            , Effect.none
            )

        ClickCancel ->
            ( { model | inputUrl = shared.apiUrl }
            , Effect.none
            )

        ClickSave url ->
            ( { model | changed = False }
            , Effect.saveSettings model.inputUrl
                model.inputKey
                model.localTest
            )

        PressedKey (Control "Enter") ->
            if model.changed then
                ( { model | changed = False }
                , Effect.saveSettings model.inputUrl
                    model.inputKey
                    model.localTest
                )

            else
                ( model, Effect.none )

        PressedKey _ ->
            ( model, Effect.none )

        ToggleTest ->
            ( { model | localTest = not model.localTest, changed = True }
            , Effect.none
            )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Browser.Events.onKeyDown keyDecoder


keyDecoder : Json.Decode.Decoder Msg
keyDecoder =
    Json.Decode.map PressedKey (Json.Decode.field "key" (Json.Decode.string |> Json.Decode.andThen toKeyDecoder))



-- VIEW


view : Shared.Model -> Model -> View Msg
view shared model =
    { title = "Settings"
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
                        [ text "← Home" ]
                    ]
                ]
            ]
        , form []
            [ div [ css [ Tw.max_w_md ] ]
                [ inputLicense model.inputKey
                , div [ css [ Tw.mt_4 ] ] [ inputApiUrl model.inputUrl ]
                , div [ css [ Tw.mt_4 ] ] [ toggleTestButton model.localTest ]
                , saveButton model.changed model.inputUrl
                ]
            ]
        ]
    }



-- Failure _ ->
--       { title = "Home"
--       , body = [ div [] [ text "Failed to get timezone..." ] ]
--       }
-- _ ->
--       { title = "Home"
--       , body = [ div [] [ text "Loading..." ] ]
--       }


inputApiUrl : Maybe String -> Html Msg
inputApiUrl apiUrl =
    div []
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
                    , case apiUrl of
                        Just url ->
                            Attr.value url

                        Nothing ->
                            Attr.placeholder "api.example.com"
                    ]
                    []
                ]
            ]
        ]


inputLicense : Maybe String -> Html Msg
inputLicense license =
    div []
        [ label
            [ Attr.for "license-key"
            , css
                [ Tw.block
                , Tw.text_sm
                , Tw.font_medium
                , Tw.leading_6
                , Tw.text_color Theme.gray_900
                ]
            ]
            [ text "License Key" ]
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
                [ input
                    [ Attr.type_ "text"
                    , Attr.name "api-url"
                    , Attr.id "api-url"
                    , Events.onInput UpdateLicense
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
                    , case license of
                        Just license_ ->
                            Attr.value license_

                        Nothing ->
                            Attr.placeholder "XXX-XXX-XXX"
                    ]
                    []
                ]
            ]
        ]


toggleTestButton : Bool -> Html Msg
toggleTestButton enabled =
    div
        [ css
            [ Tw.flex
            , Tw.items_center
            , Tw.justify_between
            ]
        ]
        [ span
            [ css
                [ Tw.flex
                , Tw.flex_grow
                , Tw.flex_col
                ]
            ]
            [ span
                [ css
                    [ Tw.text_sm
                    , Tw.font_medium
                    , Tw.leading_6
                    , Tw.text_color Theme.gray_900
                    ]
                , Attr.id "availability-label"
                ]
                [ text "View Test Data" ]
            , span
                [ css
                    [ Tw.text_sm
                    , Tw.text_color Theme.gray_500
                    , Tw.max_w_sm
                    , Tw.mt_1
                    ]
                , Attr.id "availability-description"
                ]
                [ text "When this setting is enabled the dashboard will show data from test Pomodoros." ]
            ]
        , {- Enabled: "bg-indigo-600", Not Enabled: "bg-gray-200" -}
          button
            [ Attr.type_ "button"
            , Events.onClick ToggleTest
            , css
                [ if enabled then
                    Tw.bg_color Theme.indigo_600

                  else
                    Tw.bg_color Theme.gray_200
                , Tw.relative
                , Tw.inline_flex
                , Tw.h_6
                , Tw.w_11
                , Tw.flex_shrink_0
                , Tw.cursor_pointer
                , Tw.rounded_full
                , Tw.border_2
                , Tw.border_color Theme.transparent
                , Tw.transition_colors
                , Tw.duration_200
                , Tw.ease_in_out
                , Css.focus
                    [ Tw.outline_none
                    , Tw.ring_2
                    , Tw.ring_color Theme.indigo_600
                    , Tw.ring_offset_2
                    ]
                ]
            , Attr.attribute "role" "switch"
            , if enabled then
                Attr.attribute "aria-checked" "false"

              else
                Attr.attribute "aria-checked" "true"
            , Attr.attribute "aria-labelledby" "availability-label"
            , Attr.attribute "aria-describedby" "availability-description"
            ]
            [ {- Enabled: "translate-x-5", Not Enabled: "translate-x-0" -}
              span
                [ Attr.attribute "aria-hidden" "true"
                , css
                    [ if enabled then
                        Tw.translate_x_5

                      else
                        Tw.translate_x_0
                    , Tw.pointer_events_none
                    , Tw.inline_block
                    , Tw.h_5
                    , Tw.w_5
                    , Tw.transform
                    , Tw.rounded_full
                    , Tw.bg_color Theme.white
                    , Tw.shadow
                    , Tw.ring_0
                    , Tw.transition
                    , Tw.duration_200
                    , Tw.ease_in_out
                    ]
                ]
                []
            ]
        ]


saveButton : Bool -> Maybe String -> Html Msg
saveButton changed url =
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
            , Events.onClick ClickCancel
            , css
                [ Tw.text_sm
                , Tw.font_semibold
                , Tw.leading_6
                , Tw.text_color Theme.gray_900
                ]
            ]
            [ text "Cancel" ]
        , button
            (if changed then
                [ Attr.type_ "button"
                , Events.onClick (ClickSave url)
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

             else
                [ Attr.type_ "disabled"
                , css
                    [ Tw.rounded_md
                    , Tw.bg_color Theme.gray_400
                    , Tw.px_3
                    , Tw.py_2
                    , Tw.text_sm
                    , Tw.font_semibold
                    , Tw.text_color Theme.white
                    , Tw.opacity_50
                    , Tw.cursor_not_allowed
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
            )
            [ text "Save" ]
        ]


toKeyDecoder : String -> Json.Decode.Decoder Key
toKeyDecoder string =
    case String.uncons string of
        Just ( char, "" ) ->
            Json.Decode.succeed (Character char)

        _ ->
            Json.Decode.succeed (Control string)
