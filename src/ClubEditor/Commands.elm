module ClubEditor.Commands exposing (..)

import ClubEditor.Models exposing (Club, encodeClub, decodeClub)
import ClubEditor.Messages exposing (Msg(..))
import Http
import Json.Decode
import Json.Encode
import Task exposing (andThen, succeed)
import Process exposing (sleep)
import Commands exposing (fetch, clubUrl)
import Messages


serialized : Json.Encode.Value -> String
serialized v =
    Json.Encode.encode 0 v


updateClub : Club -> Cmd Msg
updateClub club =
    Http.post decodeClub clubUrl (Http.string (serialized (encodeClub club)))
        |> Task.perform UpdateClubFailed UpdateClubDone


closeSystemMessage : Cmd Msg
closeSystemMessage =
    (sleep 300 `andThen` \_ -> (succeed 0)) |> Task.perform never HideSystemMessage


never : Never -> a
never n =
    never n
