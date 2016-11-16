module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model, decodeBoxState)
import Commands exposing (fetch)
import ClubEditor.Update
import ClubEditor.Messages
import Json.Decode


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClubEditorMsg (ClubEditor.Messages.Dispatch (ClubEditor.Messages.RefetchClub)) ->
            Debug.log ("model:: " ++ (toString model))
                ( model, fetch )

        ClubEditorMsg subMsg ->
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
                            }
            in
                ( { model | clubEditor = Just newClubEditor }, Cmd.none )

        FetchFailed error ->
            ( model, Cmd.none )

        GotTime now ->
            ( { model | time = now / 1000}, Cmd.none )

        BoxStateUpdate box ->
            let
                result = Json.Decode.decodeString decodeBoxState box
            in
                case result of
                    Ok boxState ->
                        Debug.log(toString boxState.color)
                        ( { model | boxState = Just boxState }, Cmd.none )
                    Err err -> 
                        Debug.log("error decoding box state " ++ (toString err))
                        ( model, Cmd.none )
                        
