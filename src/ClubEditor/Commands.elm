module ClubEditor.Commands exposing (..)
import ClubEditor.Models exposing (Club, encodeClub, decodeClub)
import Commands exposing (clubUrl)
import ClubEditor.Messages exposing (Msg(..))

import Http
import Json.Decode
import Json.Encode
import Task

serialized : Json.Encode.Value -> String
serialized v =
    Json.Encode.encode 0 v

updateClub : Club -> Cmd Msg
updateClub club = 
    Http.post decodeClub clubUrl (Http.string (serialized (encodeClub club)))
        |> Task.perform UpdateClubFailed UpdateClubDone
