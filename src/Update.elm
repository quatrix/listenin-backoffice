module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)

import ClubEditor.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClubEditorMsg subMsg ->
            let
                ( updatedClubEditor, cmd ) =
                    ClubEditor.Update.update subMsg model.clubEditor
            in
                ( { model | clubEditor = updatedClubEditor }, Cmd.map ClubEditorMsg cmd )
        GotTime now ->
                ( { model | time = now }, Cmd.none )
