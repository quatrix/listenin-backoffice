port module ClubEditor.Update exposing (..)

import ClubEditor.Messages exposing (Msg(..), DispatchMsg(..))
import ClubEditor.Models exposing (..)
import ClubEditor.Commands exposing (updateClub, closeSystemMessage, toggleSample)
import String


port play : String -> Cmd msg


port stop : String -> Cmd msg


update : Msg -> ClubEditor -> ( ClubEditor, Cmd Msg, Maybe DispatchMsg )
update message model =
    let
        club =
            model.club
    in
        case message of
            Play url ->
                ( { model | playing = url }, play url, Nothing )

            Stop ->
                ( { model | playing = "" }, stop "", Nothing )

            ToggleSampleVisibility sample_id ->
                let
                    samples =
                        toggleSampleVisibility sample_id model.club.samples

                    club =
                        { club | samples = samples }

                    msg =
                        { isLoading = True
                        , msg = "Saving..."
                        , msgType = Info
                        }
                in
                    ( { model | club = club, systemMessage = Just msg }, (toggleSample model.token sample_id) , Nothing )

            ToggleSampleDone res -> 
                let
                    msg =
                        { isLoading = False
                        , msg = "Done..."
                        , msgType = Success
                        }
                in
                    ( { model | systemMessage = Just msg }, closeSystemMessage, Nothing )

            ToggleSampleFailed error ->
                let
                    msg =
                        { isLoading = False
                        , msg = (toString error)
                        , msgType = Error
                        }
                in
                    ( { model | systemMessage = Just msg }, Cmd.none, Just RefetchClub )

            UpdateClubDone club ->
                let
                    msg =
                        { isLoading = False
                        , msg = "Done..."
                        , msgType = Success
                        }
                in
                    ( { model | club = club, systemMessage = Just msg }, closeSystemMessage, Nothing )

            UpdateClubFailed error ->
                let
                    msg =
                        { isLoading = False
                        , msg = (toString error)
                        , msgType = Error
                        }
                in
                    ( { model | club = club, systemMessage = Just msg }, Cmd.none, Just RefetchClub )

            DescriptionChanged description ->
                ( { model | club = { club | details = description } }, Cmd.none, Nothing )

            ToggleTag tag ->
                ( { model | club = { club | tags = (toggleTag model.club.tags tag) } }, Cmd.none, Nothing )

            Save ->
                let
                    msg =
                        { isLoading = True
                        , msg = "Saving..."
                        , msgType = Info
                        }
                in
                    ( { model
                        | systemMessage = Just msg
                        , isClubEditWindowVisible = False
                      }
                    , (updateClub model.token model.club)
                    , Nothing
                    )

            OpenClubEditWindow ->
                ( { model | isClubEditWindowVisible = not model.isClubEditWindowVisible }, Cmd.none, Nothing )

            CloseClubEditWindow ->
                ( { model | isClubEditWindowVisible = False }, Cmd.none, Nothing )

            SubmitStopEvent stopButtonType howLong ->
                case stopButtonType of
                    StopPublishing ->
                        updateStop { club | stopPublishing = howLong } model

                    StopRecognition ->
                        updateStop { club | stopRecognition = howLong } model

                    StopRecording ->
                        updateStop { club | stopRecording = howLong } model

            ResumeStopped stopButtonType stopMsg ->
                update (SubmitStopEvent stopButtonType 0) model

            CloseForHowLongModal ->
                ( { model | showForHowLongBox = Nothing }, Cmd.none, Nothing )

            AskForHowLong buttonType msg ->
                ( { model | showForHowLongBox = Just buttonType, stopMsg = msg }, Cmd.none, Nothing )

            HideSystemMessage i ->
                ( { model | systemMessage = Nothing }, Cmd.none, Nothing )

            Dispatch i ->
                ( model, Cmd.none, Nothing )


updateStop : Club -> ClubEditor -> ( ClubEditor, Cmd Msg, Maybe DispatchMsg )
updateStop club model =
    let
        next =
            { model | club = club, showForHowLongBox = Nothing }
    in
        update Save next


toggleTag : List String -> String -> List String
toggleTag tags tag =
    if isIn tag tags then
        List.filter (\x -> (String.toLower x) /= (String.toLower tag)) tags
    else
        List.append tags [ tag ]


isIn : String -> List String -> Bool
isIn niddle hay =
    not (List.isEmpty (List.filter (\x -> (String.toLower x) == (String.toLower niddle)) hay))


flipHiddenIfMatches : Int -> Sample -> Sample
flipHiddenIfMatches sample_id sample =
    if sample.id == sample_id then
        let
            metadata =
                sample.metadata

            newMetadata =
                { metadata | hidden = not metadata.hidden }
        in
            { sample | metadata = newMetadata }
    else
        sample


toggleSampleVisibility : Int -> List Sample -> List Sample
toggleSampleVisibility sample_id samples =
    List.map (flipHiddenIfMatches sample_id) samples
