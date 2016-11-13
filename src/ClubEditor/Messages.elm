module ClubEditor.Messages exposing (..)

import ClubEditor.Models exposing (Club, StopButton, SystemMessage)
import Http


type DispatchMsg
    = RefetchClub


type Msg
    = Play String
    | ToggleSampleVisibility String
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
    | UpdateClubDone Club
    | UpdateClubFailed Http.Error
    | HideSystemMessage Int
    | Dispatch DispatchMsg
