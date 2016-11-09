module Club.Messages exposing (..)
import Club.Models exposing (Club)
import Http

type Msg
    = FetchDone Club
    | FetchFailed Http.Error
    | Play String
    | Delete String
    | Stop
    | DescriptionChanged String
