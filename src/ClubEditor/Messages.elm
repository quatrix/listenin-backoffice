module ClubEditor.Messages exposing (..)

import ClubEditor.Models exposing (Club, StopButton, SystemMessage, ServerResponse)
import Http


type DispatchMsg
    = RefetchClub


type Msg
    = Play String
    | ToggleSampleVisibility Int
    | Stop
    | Save
    | DescriptionChanged String
    | ToggleTag String
    | AskForHowLong StopButton String
    | ResumeStopped StopButton String
    | SubmitStopEvent StopButton Int
    | CloseForHowLongModal
    | OpenClubEditWindow
    | CloseClubEditWindow
    | UpdateClubDone Club
    | UpdateClubFailed Http.Error
    | ToggleSampleDone ServerResponse
    | ToggleSampleFailed Http.Error
    | HideSystemMessage Int
    | Dispatch DispatchMsg
