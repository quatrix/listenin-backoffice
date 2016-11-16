module View exposing (..)

import Html exposing (Html, div, text)
import Html.Attributes exposing (class, style)
import Html.App
import Messages exposing (Msg)
import Models exposing (Model)
import ClubEditor.View
import Messages exposing (..)


view : Model -> Html Msg
view model =
    case model.clubEditor of
        Just clubEditor ->
            div [class "flex fit", style [("background-color", "#F5F5F5")]]
                [ div [class "sm-col-5", style [("font-family", "Lato-Light")]] 
                    [ Html.App.map ClubEditorMsg (ClubEditor.View.view clubEditor model.time model.boxState) ]
                ]

        Nothing ->
            div [] [ text "Loading..." ]
