module Login.Commands exposing (..)
import Login.Messages exposing (Msg(..))
import Login.Models exposing (decodeLoginResponse)

import Http
import Task


getToken : String -> String -> Cmd Msg
getToken username password =
    Http.get decodeLoginResponse (getTokenUrl username password)
        |> Task.perform LoginFailed LoginOk

tokenUrl : String
tokenUrl =
    "http://localhost:55669/token"

getTokenUrl : String -> String -> String
getTokenUrl username password =
    tokenUrl ++ "?username=" ++ username ++ "&password=" ++ password
