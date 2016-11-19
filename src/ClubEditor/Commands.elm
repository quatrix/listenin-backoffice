module ClubEditor.Commands exposing (..)

import ClubEditor.Models exposing (Club, encodeClub, decodeClub, decodeServerResponse)
import ClubEditor.Messages exposing (Msg(..))
import Http
import Json.Decode
import Json.Encode
import Task exposing (andThen, succeed)
import Process exposing (sleep)
import Commands exposing (apiUrl, getClubUrl)
import Messages


serialized : Json.Encode.Value -> String
serialized v =
    Json.Encode.encode 0 v


updateClub : String -> Club -> Cmd Msg
updateClub token club =
    Http.post decodeClub (getClubUrl token) (Http.string (serialized (encodeClub club)))
        |> Task.perform UpdateClubFailed UpdateClubDone


toggleSample : String -> Int -> Cmd Msg
toggleSample token sample_id =
    Http.post decodeServerResponse (getToggleSampleUrl token sample_id) Http.empty
        |> Task.perform ToggleSampleFailed ToggleSampleDone

getToggleSampleUrl : String -> Int -> String
getToggleSampleUrl token sample_id =
    apiUrl ++ "/bo/samples?token=" ++ token ++ "&sample_id=" ++ (toString sample_id)

closeSystemMessage : Cmd Msg
closeSystemMessage =
    (sleep 300 `andThen` \_ -> (succeed 0)) |> Task.perform never HideSystemMessage


never : Never -> a
never n =
    never n
