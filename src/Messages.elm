module Messages exposing (..)
import Club.Messages
import Time exposing (Time)


type Msg
    = ClubMsg Club.Messages.Msg
    | GotTime Time
