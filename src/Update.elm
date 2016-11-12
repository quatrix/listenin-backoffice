module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)
import ClubEditor.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClubEditorMsg subMsg ->
            case model.clubEditor of
                Just clubEditor ->
                    let
                        ( updatedClubEditor, cmd ) =
                            ClubEditor.Update.update subMsg clubEditor
                    in
                        ( { model | clubEditor = Just updatedClubEditor }, Cmd.map ClubEditorMsg cmd )

                Nothing ->
                    ( model, Cmd.none )

        FetchDone club ->
            let
                clubEditor =
                    { club = club
                    , isClubEditWindowVisible = False
                    , playing = ""
                    , showForHowLongBox = Nothing
                    , systemMessage = Nothing
                    }
            in
                ( { model | clubEditor = Just clubEditor }, Cmd.none )

        FetchFailed error ->
            ( model, Cmd.none )

        GotTime now ->
            ( { model | time = now }, Cmd.none )

