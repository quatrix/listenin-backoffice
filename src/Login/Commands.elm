module Login.Commands exposing (..)
import Login.Messages exposing (Msg(..))
import Login.Models exposing (decodeLoginResponse, encodeTokenRequest, TokenRequest)
import ClubEditor.Commands exposing (serialized)
import Commands exposing (apiUrl)

import Http
import Task


getToken: String -> String -> Cmd Msg
getToken username password =
    let
        request = 
            { username = username
            , password = password
            }
    in
        Http.post decodeLoginResponse getTokenUrl (Http.string (serialized (encodeTokenRequest request)))
        |> Task.perform LoginFailed LoginOk

getTokenUrl : String
getTokenUrl =
    apiUrl ++ "/token"
