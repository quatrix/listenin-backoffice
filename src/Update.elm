module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model, decodeBoxState)
import Commands exposing (fetch)
import ClubEditor.Update
import ClubEditor.Messages
import Login.Update
import Login.Messages
import Json.Decode
import Maybe exposing (withDefault)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClubEditorMsg (ClubEditor.Messages.Dispatch (ClubEditor.Messages.RefetchClub)) ->
            case model.login.token of
                Just token ->
                    ( model, (fetch token))
                Nothing -> 
                    ( model, Cmd.none)

        LoginMsg (Login.Messages.Dispatch (Login.Messages.FetchClub)) ->
            case model.login.token of
                Just token ->
                    ( model, (fetch token))
                Nothing -> 
                    ( model, Cmd.none)

        LoginMsg subMsg ->
            let
                ( updatedLogin, loginCmd, dispatchMsg ) =
                    Login.Update.update subMsg model.login

                newModel =
                    { model | login = updatedLogin }

                cmd =
                    Cmd.map LoginMsg loginCmd
            in
                case dispatchMsg of
                    Just m ->
                        let
                            ( dispatchChildModel, dispatchChildCmd ) =
                                update (LoginMsg <| Login.Messages.Dispatch m) newModel
                        in
                            ( dispatchChildModel, Cmd.batch [ cmd, dispatchChildCmd ] )

                    Nothing ->
                        ( newModel, cmd )


        ClubEditorMsg subMsg ->
            handleClubEditorMsg model subMsg

        FetchDone club ->
            let
                newClubEditor =
                    case model.clubEditor of
                        Just clubEditor ->
                            { clubEditor | club = club }

                        Nothing ->
                            { club = club
                            , isClubEditWindowVisible = False
                            , playing = ""
                            , showForHowLongBox = Nothing
                            , systemMessage = Nothing
                            , stopMsg = ""
                            , token = (withDefault "" model.login.token)
                            }
            in
                ( { model | clubEditor = Just newClubEditor }, Cmd.none )

        FetchFailed error ->
            Debug.log("omg: " ++ (toString error))
            ( model, Cmd.none )

        Tick now ->
            ( { model | time = now / 1000}, Cmd.none )

        BoxStateUpdate box ->
            let
                result = Json.Decode.decodeString decodeBoxState box
            in
                case result of
                    Ok boxState ->
                        ( { model | boxState = Just boxState }, Cmd.none )
                    Err err -> 
                        Debug.log("error decoding box state " ++ (toString err))
                        ( model, Cmd.none )
                        

handleClubEditorMsg : Model -> ClubEditor.Messages.Msg -> ( Model, Cmd Msg )
handleClubEditorMsg model subMsg =
    case model.clubEditor of
        Just clubEditor ->
            let
                ( updatedClubEditor, childCmd, dispatchMsg ) =
                    ClubEditor.Update.update subMsg clubEditor

                newModel =
                    { model | clubEditor = Just updatedClubEditor }

                cmd =
                    Cmd.map ClubEditorMsg childCmd
            in
                case dispatchMsg of
                    Just m ->
                        let
                            ( dispatchChildModel, dispatchChildCmd ) =
                                update (ClubEditorMsg <| ClubEditor.Messages.Dispatch m) newModel
                        in
                            ( dispatchChildModel, Cmd.batch [ cmd, dispatchChildCmd ] )

                    Nothing ->
                        ( newModel, cmd )

        Nothing ->
                ( model, Cmd.none )
