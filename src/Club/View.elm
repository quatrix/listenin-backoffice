module Club.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class, controls, type', src, id, checked, height, rows)
import Html.App
import Html.Events exposing (onClick, onInput)
import Club.Models exposing (Club, Sample, SampleMetadataRecognized_song)
import Club.Update exposing (isIn)
import Club.Messages exposing (..)
import Messages
import Time exposing (Time)
import Date

view : Club -> Time -> Html Msg
view club time =
    div [class "clearfix"]
        [ div[class "flex h1"] [
              img [src club.logo.xxxhdpi, style [("width", "50px"), ("height", "50px")]] []
            , text club.name
            ]
        , div[class "p2 bg-white border rounded sm-col-6 my1"] [
            div[] [text "Description", textarea [class "textarea", rows 3, onInput DescriptionChanged] [text club.details]]
            , div []
                (List.map (toCheckbox club.tags) [
                    "Smoking", "Food", "Dancing", "Tables", "LGBT", "Small", "Large"
                ])
            , div[] [button [class "btn btn-primary", onClick Save] [text "Save"]]
        ]
        , div[] [ stopButton (AskForHowLong StopPublishing) "Remove from club list"
                , stopButton (AskForHowLong StopRecording) "Stop recording"
                , stopButton (AskForHowLong StopRecognition) "Stop recognizing"
                ]
        , forHowLongBox club.showForHowLongBox
        , audio
            [ id "audio-player"
            , controls False
            ]
            []
        , sampleList club.samples time club.playing
        ]


stopButton : Msg -> String -> Html Msg
stopButton stopType lable = 
    button [class "btn btn-primary bg-red mr1", onClick stopType] [ text lable ]


forHowLongBox : Bool -> Html Msg
forHowLongBox visible =
    if visible then
        div [] [ button[] [text "1 Hour"]
               , button[] [text "2 Hours"]
               , button[] [text "Forever"]
               , button[] [text "Custom"]
        ]
    else
        div [] []

toCheckbox : List String -> String -> Html Msg
toCheckbox enabledTags tag =
    checkbox (ToggleTag tag) tag (isIn tag enabledTags) 


checkbox : msg -> String -> Bool -> Html msg
checkbox msg name isChecked =
  label
    [ style [("padding", "5px")]
    ]
    [ input [ type' "checkbox", onClick msg, checked isChecked ] []
    , text name
    ]


sampleList : List Sample -> Time -> String -> Html Msg
sampleList samples time playing =
    div[ class "p2" ] 
    [
    table [] 
    [ thead[]
        [ tr[]
            [ th[] [text "name"]
            , th[] [text "when"]
            , th[] [text "play"]
            , th[] [text "remove"]
            ]
        ]
    , tbody[] (List.map (sampleRow time playing ) samples )
    ]
    ]



sampleRow : Time -> String -> Sample -> Html Msg
sampleRow time playing sample =
    let 
        recognized_song = sample.metadata.recognized_song 
        name = case recognized_song of
            Just a ->
                Maybe.withDefault "" (List.head a.artists) ++ " - " ++ a.title
            Nothing -> 
                "Unknown Title"
    in
        tr []
        [ td [] [ text name ]
        , td [] [ text (humanizeTime time sample.date) ]
        , td [] [ playButton playing sample.link ]
        , td [] [ button [ class "btn btn-small bg-red", onClick (Delete sample.date) ] [ text "delete"] ]
        ]

playButton : String -> String -> Html Msg
playButton playing link =
    if playing == link then
        button [ class "btn btn-small bg-blue", onClick (Stop) ] [ text "stop" ]
    else
        button [ class "btn btn-small bg-blue", onClick (Play link) ] [ text "play"]

toTimeAgo : Time -> String
toTimeAgo secondDiff =
    if secondDiff < 60 then
        (toString secondDiff) ++ " seconds ago"
    else if secondDiff < 120 then
        "About a minute ago"
    else if secondDiff < 3600 then
        (toString (secondDiff // 60)) ++ " minutes ago"
    else if secondDiff < 7200 then
        "About an hour ago"
    else if secondDiff < 86400 then
        "About " ++ toString(secondDiff // 3600) ++ " hours ago"
    else if secondDiff < 172800 then
        "Yesterday"
    else
        (toString (secondDiff // 86400)) ++ " days ago"


humanizeTime : Time -> String -> String
humanizeTime currentTime sampleTime  =
    let
        r = Date.fromString sampleTime
    
    in
        case r of
            Result.Ok d ->
                toTimeAgo((currentTime / 1000) - ((Date.toTime d) / 1000))
            Result.Err e ->
                toString e 
