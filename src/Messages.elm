module Messages exposing (..)

import ClubEditor.Messages
import Login.Messages
import ClubEditor.Models exposing (Club)
import Time exposing (Time)
import Http


type Msg
    = ClubEditorMsg ClubEditor.Messages.Msg
    | LoginMsg Login.Messages.Msg
    | Tick Time
    | FetchDone Club
    | FetchFailed Http.Error
    | BoxStateUpdate String
