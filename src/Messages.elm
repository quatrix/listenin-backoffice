module Messages exposing (..)
import ClubEditor.Messages
import Time exposing (Time)


type Msg
    = ClubEditorMsg ClubEditor.Messages.Msg
    | GotTime Time
