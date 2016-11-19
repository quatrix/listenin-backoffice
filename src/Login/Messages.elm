module Login.Messages exposing (..)
import Login.Models exposing (LoginResponse)
import Http

type DispatchMsg
    = FetchClub

type Msg
    = Username String
    | Password String
    | LoginFailed Http.Error
    | LoginOk LoginResponse
    | Submit
    | Dispatch DispatchMsg
