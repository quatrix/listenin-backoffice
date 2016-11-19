module Main exposing (..)

import Html.App
import Messages exposing (Msg(..))
import Models exposing (Model, initialModel)
import View exposing (view)
import Update exposing (update)
import Commands exposing (..)
import ClubEditor.Commands exposing (..)
import WebSocket
import Time exposing (every, second)


init : ( Model, Cmd Msg )
init =
    ( initialModel, getTime )


subscriptions : Model -> Sub Msg
subscriptions model =
    case model.login.token of
        Just token ->
            Sub.batch 
                [ WebSocket.listen (getWSUrl token) BoxStateUpdate
                , every second Tick
                ]
        Nothing ->
            Sub.none

getWSUrl : String -> String
getWSUrl token =
    wsUrl ++ "?token=" ++ token

wsUrl : String
wsUrl =
    "ws://listenin.io:9998/updates/"

-- MAIN


main : Program Never
main =
    Html.App.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
