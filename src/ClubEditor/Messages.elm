module ClubEditor.Messages exposing (..)
import ClubEditor.Models exposing (Club, StopButton)
import Http


type Msg
    = FetchDone Club
    | FetchFailed Http.Error
    | Play String
    | Delete String
    | Stop
    | Save
    | DescriptionChanged String
    | ToggleTag String
    | AskForHowLong StopButton
    | ResumeStopped StopButton
    | SubmitStopEvent StopButton Int
    | CloseForHowLongModal
    | OpenClubEditWindow
    | CloseClubEditWindow
