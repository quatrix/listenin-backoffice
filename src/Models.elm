module Models exposing (..)

import ClubEditor.Models exposing (ClubEditor, Club, Logo)
import Login.Models exposing (Login)
import Time exposing (Time)
import Json.Decode exposing ((:=))
import Json.Decode.Extra exposing ((|:), withDefault)

type alias Model =
    { clubEditor : Maybe ClubEditor
    , time : Time
    , boxState : Maybe BoxState
    , login : Login
    }

type alias BoxState =
    { blink : Maybe BoxStateValue
    , color : Maybe BoxStateValue
    , status : Maybe BoxStateValue
    }

type alias BoxStateValue =
    { time : Int
    , value : String
    }


decodeBoxState : Json.Decode.Decoder BoxState
decodeBoxState =
    Json.Decode.succeed BoxState
        |: (Json.Decode.oneOf[ ("blink" := (Json.Decode.maybe decodeBoxStateValue)), Json.Decode.succeed Nothing])
        |: (Json.Decode.oneOf[ ("color" := (Json.Decode.maybe decodeBoxStateValue)), Json.Decode.succeed Nothing])
        |: (Json.Decode.oneOf[ ("status" := (Json.Decode.maybe decodeBoxStateValue)), Json.Decode.succeed Nothing])


decodeBoxStateValue : Json.Decode.Decoder BoxStateValue
decodeBoxStateValue =
    Json.Decode.succeed BoxStateValue
        |: ("time" := Json.Decode.int)
        |: ("value" := Json.Decode.string)

initialModel : Model
initialModel =
    { clubEditor = Nothing
    , time = 0.0
    , boxState = Nothing
    , login = {error = Nothing, token = Nothing, username = "", password = ""}
    }
