module ClubEditor.Models exposing (..)
import Json.Decode exposing ((:=))
import Json.Decode.Extra exposing ((|:), withDefault)

type StopButton
    = StopRecording
    | StopPublishing
    | StopRecognition

type alias ClubEditor =
    { club : Club
    , playing : String
    , showForHowLongBox: Maybe StopButton
    , isClubEditWindowVisible : Bool
    }

type alias Club =
    { name : String
    , tags : List String
    , logo : Logo
    , details : String
    , samples : List Sample
    , stopPublishing : Maybe Int
    , stopRecording : Maybe Int
    , stopRecognition : Maybe Int
    }

type alias Sample =
    { date : String
    , link : String
    , metadata : SampleMetadata
    }

type alias Logo =
    { xxxhdpi: String
    }

type alias SampleMetadataRecognized_song =
    { album : String
    , genres : List String
    , artists : List String
    , title : String
    }

type alias SampleMetadata =
    { recognized_song : Maybe SampleMetadataRecognized_song
    }

decodeClub : Json.Decode.Decoder Club
decodeClub =
    Json.Decode.succeed Club
        |: ("name" := Json.Decode.string)
        |: ("tags" := Json.Decode.list Json.Decode.string)
        |: ("logo" := decodeLogo)
        |: ("details" := Json.Decode.string)
        |: ("samples" := Json.Decode.list decodeSample)
        |: (("stopRecording" := Json.Decode.maybe Json.Decode.int) |> (withDefault Nothing))
        |: (("stopPublishing" := Json.Decode.maybe Json.Decode.int) |> (withDefault Nothing))
        |: (("stopRecognition" := Json.Decode.maybe Json.Decode.int) |> (withDefault Nothing))

decodeLogo : Json.Decode.Decoder Logo
decodeLogo =
    Json.Decode.succeed Logo
        |: ("xxxhdpi" := Json.Decode.string)

decodeSample : Json.Decode.Decoder Sample
decodeSample =
    Json.Decode.succeed Sample
        |: ("date" := Json.Decode.string)
        |: ("link" := Json.Decode.string)
        |: ("metadata" := decodeSampleMetadata)

decodeSampleMetadata : Json.Decode.Decoder SampleMetadata
decodeSampleMetadata =
    Json.Decode.succeed SampleMetadata
        |: ("recognized_song" := Json.Decode.maybe decodeSampleMetadataRecognized_song)

decodeSampleMetadataRecognized_song : Json.Decode.Decoder SampleMetadataRecognized_song
decodeSampleMetadataRecognized_song =
    Json.Decode.succeed SampleMetadataRecognized_song
        |: ("album" := Json.Decode.string)
        |: ("genres" := Json.Decode.list Json.Decode.string)
        |: ("artists" := Json.Decode.list Json.Decode.string)
        |: ("title" := Json.Decode.string)
