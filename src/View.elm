module View exposing (..)

import Html exposing (Html, div, text)
import Html.App

import Messages exposing (Msg)
import Models exposing (Model)
import Club.View
import Messages exposing (..)


view : Model -> Html Msg
view model =
    div [] 
    [ Html.App.map ClubMsg (Club.View.view model.club model.time)
    ]
