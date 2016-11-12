module Models exposing (..)
import ClubEditor.Models exposing (ClubEditor, Club, Logo)
import Time exposing (Time)

type alias Model =
    { clubEditor : Maybe ClubEditor
    , time : Time -- FIXME should be Maybe Time
    }

initialModel : Model
initialModel =
    { clubEditor = Nothing
    , time = 0.0
    }
