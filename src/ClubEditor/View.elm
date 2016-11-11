module ClubEditor.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class, controls, type', src, id, checked, rows)
import Html.App
import Html.Events exposing (onClick, onInput)
import ClubEditor.Models exposing (..)
import ClubEditor.Update exposing (isIn)
import ClubEditor.Messages exposing (..)
import Messages
import Time exposing (Time)
import Date

view : ClubEditor -> Time -> Html Msg
view clubEditor time =
    let 
        club = clubEditor.club
    in
        div [class "clearfix"]
            [ 
              header club
            , clubEditWindow clubEditor.isClubEditWindowVisible club
            , stopButtons club clubEditor.showForHowLongBox
            , audio
                [ id "audio-player"
                , controls False
                ]
                []
            , sampleList club.samples time clubEditor.playing
            ]


header : Club -> Html Msg
header club =
    div[class "flex h1 white"] [
      img [src club.logo.xxxhdpi, style [("width", "50px"), ("height", "50px")]] []
    , text club.name
    , button [class "btn btn-primary mb1 bg-teal", onClick OpenClubEditWindow] [i[class "fa fa-info mr1"][], text "Edit Info"]
    ]

clubEditWindow : Bool -> Club -> Html Msg
clubEditWindow visible club = 
    if visible then
        div [] [
            div[class "p2 bg-yellow border rounded sm-col-6 my1"] [
                div[] [
                    text "Description", 
                    textarea [class "textarea", rows 3, onInput DescriptionChanged] [text club.details]
                ]
                , div []
                (List.map (toCheckbox club.tags) [
                    "Smoking", "Food", "Dancing", "Tables", "LGBT", "Small", "Large"
                ])
            , div[] [ button [class "btn btn-primary", onClick Save] [text "Save"]
                    , button [class "btn bg-gray", onClick CloseClubEditWindow ] [text "Cancel"]
                    ]
            ] 
        ]
    else
        div[][]

stopButtons : Club -> Maybe StopButton -> Html Msg
stopButtons club showForHowLongBox =
    let 
        publishingMsg = "Published. Click to hide from club list" 
        stopPublishingMsg = "Publishing disabled, click to enable. will self enable in "
        recordingMsg = "Recording. click to stop." 
        stopRecordingMsg = "Recording disabled, click to enable. will self enable in "
        recognizingMsg = "Recognizing. click to stop."
        stopRecognizingMsg =  "Sample recognition disabled. click to enable. will self enable in "
    in
        div[class "sm-col-6 bg-orange border"] [ 
            stopButton club.stopPublishing StopPublishing "fa-lock" publishingMsg stopPublishingMsg
          , stopButton club.stopRecording StopRecording "fa-circle" recordingMsg stopRecordingMsg 
          , stopButton club.stopRecognition StopRecognition "fa-eye" recognizingMsg stopRecognizingMsg
          , forHowLongBox showForHowLongBox
        ]

stopButton : Maybe Int -> StopButton -> String -> String -> String -> Html Msg
stopButton disabledFor stopType icon disablingLable enablingLable = 
    let
        buttonStyle = style [("width", "150px"), ("height", "200px")]
    in
        case disabledFor of
            Just forHowLog ->
                button [class "btn btn-primary bg-red mr1", buttonStyle, onClick (ResumeStopped stopType)] [ div [ class ("fa " ++ icon ++ " my1") ] [], div [] [ text (enablingLable ++ (toString forHowLog))]]
            Nothing -> 
                button [class "btn btn-primary bg-green mr1", buttonStyle, onClick (AskForHowLong stopType)] [ div [ class ("fa " ++ icon ++ " my1") ] [], div [] [ text disablingLable ]]


forHowLongBox : Maybe StopButton -> Html Msg
forHowLongBox stopButtonType =
    case stopButtonType of
        Just stopButton -> 
            div [] [
                div[class "h3"] [text "This is where an explanation goes"]
              , div [] [ button[onClick (SubmitStopEvent stopButton 1)] [text "1 Hour"]
                   , button[onClick (SubmitStopEvent stopButton 2)] [text "2 Hours"]
                   , button[onClick (SubmitStopEvent stopButton -1)] [text "Forever"]
                   , button[onClick CloseForHowLongModal] [text "Cancel"]
                ]
            ]
        Nothing ->
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
    div[ class "p2 white" ] 
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
