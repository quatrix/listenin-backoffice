module Login.Update exposing (..)

import Login.Messages exposing (Msg(..), DispatchMsg(..))
import Login.Models exposing (Login)
import Login.Commands exposing (getToken)


update : Msg -> Login -> ( Login , Cmd Msg, Maybe DispatchMsg)
update message model =
    case message of
        Username username ->
            ({model | username = username}, Cmd.none, Nothing)

        Password password ->
            ({model | password = password}, Cmd.none, Nothing)

        Submit ->
            ({model | waiting = True}, (getToken model.username model.password), Nothing)

        LoginOk login -> 
            case login.token of
                Just token ->
                    ({model | waiting = False, token = Just token}, Cmd.none, Just FetchClub)
                Nothing ->
                    ({model | waiting = False, error = Just "invalid login"}, Cmd.none, Nothing)

        LoginFailed error -> 
            ({model | waiting = False, error = Just (toString error)}, Cmd.none, Nothing)

        Dispatch i -> 
            (model, Cmd.none, Nothing)
