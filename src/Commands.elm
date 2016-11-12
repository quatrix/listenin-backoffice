module Commands exposing (..)

import ClubEditor.Models exposing (Club, decodeClub)
import Messages exposing (..)
import Time
import Http
import Task

getTime : Cmd Msg
getTime = 
    Task.perform assertNeverHandler GotTime Time.now

assertNeverHandler : a -> b
assertNeverHandler =
    (\_ -> Debug.crash "This should never happen")

fetch : Cmd Msg
fetch = 
    Http.get decodeClub clubUrl 
        |> Task.perform FetchFailed FetchDone

clubUrl : String
clubUrl =
    "http://localhost:55669/clubs?club=radio"
