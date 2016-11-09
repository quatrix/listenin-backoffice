module Update exposing (..)

import Messages exposing (Msg(..))
import Models exposing (Model)

import Club.Update


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ClubMsg subMsg ->
            let
                ( updatedClub, cmd ) =
                    Club.Update.update subMsg model.club
            in
                ( { model | club = updatedClub }, Cmd.map ClubMsg cmd )
        GotTime now ->
                ( { model | time = now }, Cmd.none )
