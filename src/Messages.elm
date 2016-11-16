module Messages exposing (..)

import ClubEditor.Messages
import ClubEditor.Models exposing (Club)
import Time exposing (Time)
import Http


type Msg
    = ClubEditorMsg ClubEditor.Messages.Msg
    | GotTime Time
    | FetchDone Club
    | FetchFailed Http.Error
    | BoxStateUpdate String
