module Main exposing (..)

import Html.App
import Messages exposing (Msg(..))
import Models exposing (Model, initialModel)
import View exposing (view)
import Update exposing (update)
import ClubEditor.Commands exposing (fetch)
import Commands exposing (..)

init : (Model, Cmd Msg)
init =
  (initialModel, Cmd.batch [getTime, (Cmd.map ClubEditorMsg fetch)])



subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MAIN


main : Program Never
main =
    Html.App.program
        { init = init 
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
