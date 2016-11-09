module Club.Commands exposing (..)

import Http
import Task
import Club.Models exposing (decodeClub, Club)
import Club.Messages exposing (..)

fetch : Cmd Msg
fetch = 
    Http.get decodeClub clubUrl 
        |> Task.perform FetchFailed FetchDone


clubUrl : String
clubUrl =
    "http://localhost:55669/clubs?club=radio"
