module ClubEditor.Messages exposing (..)

import ClubEditor.Models exposing (Club, StopButton, SystemMessage)
import Http


type Msg
    = Play String
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
    | UpdateClubDone Club
    | UpdateClubFailed Http.Error
    | HideSystemMessage Int
