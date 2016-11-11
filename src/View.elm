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
    let
        bgImage = "url(http://cdn.pcwallart.com/images/gif-tumblr-backgrounds-wallpaper-2.jpg)"
    in
        div [ style [("background-image", bgImage)]] 
        [ Html.App.map ClubEditorMsg (ClubEditor.View.view model.clubEditor model.time) ]
