module Login.Models exposing (..)
import Json.Decode
import Json.Decode exposing ((:=))
import Json.Decode.Extra exposing ((|:))

type alias Login =
    { error : Maybe String 
    , token : Maybe String
    , username : String
    , password : String
    }

type alias LoginResponse =
    { token : Maybe String }

decodeLoginResponse: Json.Decode.Decoder LoginResponse
decodeLoginResponse =
    Json.Decode.succeed LoginResponse
        |: ("token" := Json.Decode.maybe Json.Decode.string)
