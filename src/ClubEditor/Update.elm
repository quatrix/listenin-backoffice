port module ClubEditor.Update exposing (..)

import ClubEditor.Messages exposing (Msg(..))
import ClubEditor.Models exposing (..)
import ClubEditor.Commands exposing (updateClub)
import String

port play : String -> Cmd msg
port stop : String -> Cmd msg

update : Msg -> ClubEditor -> ( ClubEditor, Cmd Msg )
update message model =
    let
        club = model.club
    in
        case message of
            Play url ->
                ( { model | playing = url }, play url)
            Stop ->
                ( { model | playing = "" }, stop "")
            Delete sample ->
                ( model, Cmd.none )
            UpdateClubDone club ->
                ( { model | club = club, isClubEditWindowVisible = False}, Cmd.none)
            UpdateClubFailed error ->
                ( model, Cmd.none )
            DescriptionChanged description ->
                ( { model | club = { club | details = description }}, Cmd.none)
            ToggleTag tag ->
                ( { model | club = {club | tags = (toggleTag model.club.tags tag)}}, Cmd.none )
            Save ->
                ( model, (updateClub model.club))
            OpenClubEditWindow ->
                ( { model | isClubEditWindowVisible = not model.isClubEditWindowVisible}, Cmd.none )
            CloseClubEditWindow ->
                ( { model | isClubEditWindowVisible = False}, Cmd.none )
            SubmitStopEvent stopButtonType howLong->
                case stopButtonType of
                    StopPublishing ->
                        updateStop {club | stopPublishing = howLong} model
                    StopRecognition ->
                        updateStop {club | stopRecognition = howLong} model
                    StopRecording ->
                        updateStop {club | stopRecording = howLong} model
            ResumeStopped stopButtonType ->
                update (SubmitStopEvent stopButtonType 0) model
            CloseForHowLongModal ->
                ( { model | showForHowLongBox = Nothing }, Cmd.none )
            AskForHowLong buttonType ->
                ( { model | showForHowLongBox = Just buttonType }, Cmd.none )


updateStop : Club -> ClubEditor -> (ClubEditor, Cmd Msg)
updateStop club model =
    let 
        next = { model | club = club, showForHowLongBox = Nothing }
    in
        update Save next


toggleTag : List String -> String -> List String
toggleTag tags tag =
    if isIn tag tags then
        List.filter (\x -> (String.toLower x) /= (String.toLower tag)) tags
    else
        List.append tags [tag]

isIn : String -> List String -> Bool
isIn niddle hay =
    not (List.isEmpty (List.filter (\x -> (String.toLower x) == (String.toLower niddle)) hay))

