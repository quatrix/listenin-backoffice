module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)
import Commands exposing (fetch)
import ClubEditor.Update
import ClubEditor.Messages


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
                                    Debug.log ("vova::: " ++ toString newModel)
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
            ( { model | time = now }, Cmd.none )
