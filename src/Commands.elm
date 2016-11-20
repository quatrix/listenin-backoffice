module Commands exposing (..)

import ClubEditor.Models exposing (Club, decodeClub)
import Messages exposing (..)
import Time
import Task
import Http


fetch : String -> Cmd Msg
fetch token =
    Http.get decodeClub (getClubUrl token)
        |> Task.perform FetchFailed FetchDone


getClubUrl : String -> String
getClubUrl token = 
    apiUrl ++ "/bo?token=" ++ token


apiUrl : String
apiUrl =
    "http://api.listenin.io"


getTime : Cmd Msg
getTime =
    Task.perform assertNeverHandler Tick Time.now


assertNeverHandler : a -> b
assertNeverHandler =
    (\_ -> Debug.crash "This should never happen")
