port module Club.Update exposing (..)

import Club.Messages exposing (Msg(..))
import Club.Models exposing (Club)

port play : String -> Cmd msg
port stop : String -> Cmd msg

update : Msg -> Club -> ( Club, Cmd Msg )
update message model =
    case message of
        FetchDone club ->
            ( club, Cmd.none )
        FetchFailed error ->
            ( model, Cmd.none )
        Play url ->
            ( { model | playing = url }, play url)
        Stop ->
            ( { model | playing = "" }, stop "")
        Delete sample ->
            ( model, Cmd.none )
