module Models exposing (..)
import Club.Models exposing (Club, Logo)
import Time exposing (Time)

type alias Model =
    { club : Club
    , time : Time -- FIXME should be Maybe Time
    }

initialModel : Model
initialModel =
    { club = Club "vova" ["a","b"] (Logo "")"heh" [] "" False
    , time = 0
    }
