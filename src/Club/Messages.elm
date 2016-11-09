module Club.Messages exposing (..)
import Club.Models exposing (Club)
import Http

type StopButton
    = StopRecording
    | StopPublishing
    | StopRecognition


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
