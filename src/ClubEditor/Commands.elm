module ClubEditor.Commands exposing (..)

import Http
import Task
import ClubEditor.Models exposing (decodeClub)
import ClubEditor.Messages exposing (..)

fetch : Cmd Msg
fetch = 
    Http.get decodeClub clubUrl 
        |> Task.perform FetchFailed FetchDone


clubUrl : String
clubUrl =
    "http://localhost:55669/clubs?club=radio"
