module ClubEditor.Models exposing (..)

import Json.Encode
import Json.Decode exposing ((:=))
import Json.Decode.Extra exposing ((|:), withDefault)


type StopButton
    = StopRecording
    | StopPublishing
    | StopRecognition


type SystemMessageType
    = Error
    | Warning
    | Success
    | Info


type alias SystemMessage =
    { isLoading : Bool
    , msg : String
    , msgType : SystemMessageType
    }


type alias ServerResponse =
    { success : Bool
    , error : Maybe String
    }

type alias ClubEditor =
    { club : Club
    , playing : String
    , showForHowLongBox : Maybe StopButton
    , isClubEditWindowVisible : Bool
    , systemMessage : Maybe SystemMessage
    , stopMsg : String
    , token : String
    }


type alias Club =
    { name : String
    , tags : List String
    , logo : Logo
    , details : String
    , samples : List Sample
    , stopPublishing : Int
    , stopRecording : Int
    , stopRecognition : Int
    }


type alias Sample =
    { date : String
    , link : String
    , id : Int
    , metadata : SampleMetadata
    }


type alias Logo =
    { xxxhdpi : String
    }


type alias SampleMetadataRecognized_song =
    { album : String
    , genres : List String
    , artists : List String
    , title : String
    }


type alias SampleMetadata =
    { recognized_song : Maybe SampleMetadataRecognized_song
    , hidden : Bool
    , keep_unrecognized: Bool
    }


decodeClub : Json.Decode.Decoder Club
decodeClub =
    Json.Decode.succeed Club
        |: ("name" := Json.Decode.string)
        |: ("tags" := Json.Decode.list Json.Decode.string)
        |: ("logo" := decodeLogo)
        |: ("details" := Json.Decode.string)
        |: ("samples" := Json.Decode.list decodeSample)
        |: ("stopPublishing" := Json.Decode.int)
        |: ("stopRecording" := Json.Decode.int)
        |: ("stopRecognition" := Json.Decode.int)


decodeLogo : Json.Decode.Decoder Logo
decodeLogo =
    Json.Decode.succeed Logo
        |: ("xxxhdpi" := Json.Decode.string)

decodeServerResponse : Json.Decode.Decoder ServerResponse
decodeServerResponse =
    Json.Decode.succeed ServerResponse
        |: ("success" := Json.Decode.bool)
        |: ("error" := (Json.Decode.maybe Json.Decode.string))

decodeSample : Json.Decode.Decoder Sample
decodeSample =
    Json.Decode.succeed Sample
        |: ("date" := Json.Decode.string)
        |: ("link" := Json.Decode.string)
        |: ("_created" := Json.Decode.int)
        |: ("metadata" := decodeSampleMetadata)


decodeSampleMetadata : Json.Decode.Decoder SampleMetadata
decodeSampleMetadata =
    Json.Decode.succeed SampleMetadata
        |: Json.Decode.oneOf
            [ ("recognized_song" := Json.Decode.maybe decodeSampleMetadataRecognized_song)
            , Json.Decode.succeed Nothing
            ]
        |: ("hidden" := Json.Decode.bool)
        |: ("keep_unrecognized" := Json.Decode.bool)


decodeSampleMetadataRecognized_song : Json.Decode.Decoder SampleMetadataRecognized_song
decodeSampleMetadataRecognized_song =
    Json.Decode.succeed SampleMetadataRecognized_song
        |: ("album" := Json.Decode.string)
        |: ("genres" := Json.Decode.list Json.Decode.string)
        |: ("artists" := Json.Decode.list Json.Decode.string)
        |: ("title" := Json.Decode.string)


encodeClub : Club -> Json.Encode.Value
encodeClub record =
    Json.Encode.object
        [ ( "details", Json.Encode.string <| record.details )
        , ( "tags", Json.Encode.list <| List.map Json.Encode.string <| record.tags )
        , ( "stopPublishing", Json.Encode.int <| record.stopPublishing )
        , ( "stopRecording", Json.Encode.int <| record.stopRecording )
        , ( "stopRecognition", Json.Encode.int <| record.stopRecognition )
        ]
