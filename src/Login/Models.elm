module Login.Models exposing (..)
import Json.Decode
import Json.Decode exposing ((:=))
import Json.Decode.Extra exposing ((|:))
import Json.Encode

type alias Login =
    { error : Maybe String 
    , token : Maybe String
    , username : String
    , password : String
    , waiting : Bool
    }

type alias LoginResponse =
    { token : Maybe String }

type alias TokenRequest =
    { username: String
    , password: String
    }

decodeLoginResponse: Json.Decode.Decoder LoginResponse
decodeLoginResponse =
    Json.Decode.succeed LoginResponse
        |: ("token" := Json.Decode.maybe Json.Decode.string)


encodeTokenRequest : TokenRequest -> Json.Encode.Value
encodeTokenRequest request =
    Json.Encode.object
        [ ( "username", Json.Encode.string <| request.username )
        , ( "password", Json.Encode.string <| request.password )
        ]
