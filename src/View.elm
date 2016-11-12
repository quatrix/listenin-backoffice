module View exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (style)
import Html.App
import Messages exposing (Msg)
import Models exposing (Model)
import ClubEditor.View
import Messages exposing (..)


view : Model -> Html Msg
view model =
    case model.clubEditor of
        Just clubEditor ->
            div []
                [ Html.App.map ClubEditorMsg (ClubEditor.View.view clubEditor model.time) ]

        Nothing ->
            div [] [ text "Loading" ]
