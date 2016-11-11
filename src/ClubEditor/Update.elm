port module ClubEditor.Update exposing (..)

import ClubEditor.Messages exposing (Msg(..))
import ClubEditor.Models exposing (..)
import String

port play : String -> Cmd msg
port stop : String -> Cmd msg

update : Msg -> ClubEditor -> ( ClubEditor, Cmd Msg )
update message model =
    let
        club = model.club
    in
        case message of
            FetchDone club ->
                ( { model | club = club }, Cmd.none )
            FetchFailed error ->
                Debug.log(toString error)
                ( model, Cmd.none )
            Play url ->
                ( { model | playing = url }, play url)
            Stop ->
                ( { model | playing = "" }, stop "")
            Delete sample ->
                ( model, Cmd.none )
            DescriptionChanged description ->
                ( { model | club = { club | details = description }}, Cmd.none )
            ToggleTag tag ->
                ( { model | club = {club | tags = (toggleTag model.club.tags tag)}}, Cmd.none )
            Save ->
                ( { model | isClubEditWindowVisible = False}, Cmd.none )
            OpenClubEditWindow ->
                ( { model | isClubEditWindowVisible = not model.isClubEditWindowVisible}, Cmd.none )
            CloseClubEditWindow ->
                ( { model | isClubEditWindowVisible = False}, Cmd.none )
            SubmitStopEvent stopButtonType howLong->
                case stopButtonType of
                    StopPublishing ->
                        ( { model |
                             club = { club | stopPublishing = Just howLong }
                             , showForHowLongBox = Nothing
                         }, Cmd.none )
                    StopRecognition ->
                        ( { model |
                             club = { club | stopRecognition = Just howLong }
                             , showForHowLongBox = Nothing
                         }, Cmd.none )
                    StopRecording ->
                        ( { model |
                             club = { club | stopRecording = Just howLong }
                             , showForHowLongBox = Nothing
                         }, Cmd.none )
            ResumeStopped stopButtonType ->
                case stopButtonType of
                    StopPublishing ->
                        ( { model |
                             club = { club | stopPublishing = Nothing }
                             , showForHowLongBox = Nothing
                         }, Cmd.none )
                    StopRecognition ->
                        ( { model |
                             club = { club | stopRecognition = Nothing }
                             , showForHowLongBox = Nothing
                         }, Cmd.none )
                    StopRecording ->
                        ( { model |
                             club = { club | stopRecording = Nothing }
                             , showForHowLongBox = Nothing
                         }, Cmd.none )
            CloseForHowLongModal ->
                ( { model | showForHowLongBox = Nothing }, Cmd.none )
            AskForHowLong buttonType ->
                ( { model | showForHowLongBox = Just buttonType }, Cmd.none )



toggleTag : List String -> String -> List String
toggleTag tags tag =
    if isIn tag tags then
        List.filter (\x -> (String.toLower x) /= (String.toLower tag)) tags
    else
        List.append tags [tag]

isIn : String -> List String -> Bool
isIn niddle hay =
    not (List.isEmpty (List.filter (\x -> (String.toLower x) == (String.toLower niddle)) hay))

