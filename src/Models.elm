module Models exposing (..)
import ClubEditor.Models exposing (ClubEditor, Club, Logo)
import Time exposing (Time)

type alias Model =
    { clubEditor : ClubEditor
    , time : Time -- FIXME should be Maybe Time
    }

initialModel : Model
initialModel =
    { clubEditor = {
        club = {
              name = "Loading Club"
            , tags = []
            , logo = { xxxhdpi = "" }
            , details = ""
            , samples = []
            , stopPublishing = Nothing
            , stopRecording = Nothing
            , stopRecognition = Nothing
        }
        , playing = ""
        , showForHowLongBox = Nothing
        , isClubEditWindowVisible = False
    }
    , time = 0.0
    }
