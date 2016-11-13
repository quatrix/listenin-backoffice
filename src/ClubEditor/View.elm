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
import Date.Extra.Duration as Duration
import String


view : ClubEditor -> Time -> Html Msg
view clubEditor time =
    let
        club =
            clubEditor.club
    in
        div [ class "clearfix" ]
            [ systemMessage clubEditor.systemMessage
            , header club
            , clubEditWindow clubEditor.isClubEditWindowVisible club
            , stopButtons time club clubEditor.showForHowLongBox clubEditor.stopMsg
            , audio
                [ id "audio-player"
                , controls False
                ]
                []
            , sampleList club.samples time clubEditor.playing
            ]


systemMessage : Maybe SystemMessage -> Html Msg
systemMessage msg =
    case msg of
        Just systemMessage ->
            let
                spinner =
                    if systemMessage.isLoading then
                        i [ class "fa fa-cog fa-spin fa-2x fa-fw" ] []
                    else
                        i [] []

                closeButton =
                    case systemMessage.msgType of
                        Error ->
                            i [] [ button [ onClick (HideSystemMessage 0) ] [ text "OK" ] ]

                        Warning ->
                            i [] [ button [ onClick (HideSystemMessage 0) ] [ text "OK" ] ]

                        _ ->
                            i [] []
            in
                div [ class ("flex absolute right " ++ (getMessageClassByType systemMessage.msgType)) ]
                    [ spinner
                    , div [ class "h3" ] [ text systemMessage.msg ]
                    , closeButton
                    ]

        Nothing ->
            div [] []


getMessageClassByType : SystemMessageType -> String
getMessageClassByType t =
    case t of
        Info ->
            "bg-blue"

        Error ->
            "bg-red"

        Warning ->
            "bg-yellow"

        Success ->
            "bg-green"


header : Club -> Html Msg
header club =
    div [ class "flex h1" ]
        [ img [ src club.logo.xxxhdpi, style [ ( "width", "50px" ), ( "height", "50px" ) ] ] []
        , text club.name
        , button [ class "btn btn-primary mb1 bg-teal", onClick OpenClubEditWindow ] [ i [ class "fa fa-info mr1" ] [], text "Edit Info" ]
        ]


clubEditWindow : Bool -> Club -> Html Msg
clubEditWindow visible club =
    if visible then
        div []
            [ div [ class "p2 bg-yellow border rounded sm-col-5" ]
                [ div []
                    [ text "Description"
                    , textarea [ class "textarea", rows 3, onInput DescriptionChanged ] [ text club.details ]
                    ]
                , div []
                    (List.map (toCheckbox club.tags)
                        [ "Smoking"
                        , "Food"
                        , "Dancing"
                        , "Tables"
                        , "LGBT"
                        , "Small"
                        , "Large"
                        ]
                    )
                , div []
                    [ button [ class "btn btn-primary", onClick Save ] [ text "Save" ]
                    , button [ class "btn bg-gray", onClick CloseClubEditWindow ] [ text "Cancel" ]
                    ]
                ]
            ]
    else
        div [] []


type alias StopActionMsgs =
    { toStop : String
    , toStart : String
    , help : String
    }


stopButtons : Time -> Club -> Maybe StopButton -> String -> Html Msg
stopButtons timeNow club stopType stopMsg =
    let
        publishing =
            { toStop = "Click to hide from club list"
            , toStart = "Publishing disabled, click to enable. will self enable at "
            , help = "Control your visibility. Users won't see your club for set amount of time, or if choosing forever, we'll hide you until you click again"
            }

        recording =
            { toStop = "Recording. click to stop."
            , toStart = "Recording disabled, click to enable. will self enable at "
            , help = "Temporary stop recording, this is useful when having live music / lectures. Users will still see you listed, and can listen to older samples from before stopping recording."
            }

        recognition =
            { toStop = "Recognizing. click to stop."
            , toStart = "Sample recognition disabled. click to enable. will self enable at "
            , help = "If selected, we won't tag samples with the artist name / song title we recognize. User will only get the genre"
            }
    in
        div [ class "sm-col-5 bg-orange border" ]
            [ stopButton timeNow club.stopPublishing StopPublishing "fa-lock" publishing
            , stopButton timeNow club.stopRecording StopRecording "fa-circle" recording
            , stopButton timeNow club.stopRecognition StopRecognition "fa-headphones" recognition
            , forHowLongBox stopType stopMsg
            ]


stopButton : Time -> Int -> StopButton -> String -> StopActionMsgs -> Html Msg
stopButton timeNow forHowLong stopType icon labels =
    let
        buttonStyle =
            style [ ( "width", "150px" ), ( "height", "200px" ) ]

        iconStyle =
            style [ ( "font-size", "30px" ) ]

        buttonColorClass =
            if forHowLong == 0 then
                "bg-green"
            else
                "bg-red"

        onClickAction =
            if forHowLong == 0 then
                AskForHowLong
            else
                ResumeStopped

        label =
            if forHowLong == 0 then
                labels.toStop
            else
                (labels.toStart ++ (getHour timeNow forHowLong))
    in
        button
            [ class ("btn btn-primary " ++ buttonColorClass)
            , buttonStyle
            , onClick (onClickAction stopType labels.help)
            ]
            [ div [ iconStyle, class ("fa " ++ icon ++ " my1") ] []
            , div [] [ text label ]
            ]


getHour : Time -> Int -> String
getHour timeNow d =
    if d == -1 then
        "Never"
    else
        let
            date =
                if d < 100 then
                    Duration.add Duration.Hour d (Date.fromTime timeNow)
                else
                    Date.fromTime (d * 1000)
        in
            (String.padLeft 2 '0' (toString (Date.hour date))) ++ ":" ++ (String.padLeft 2 '0' (toString (Date.minute date)))


forHowLongBox : Maybe StopButton -> String -> Html Msg
forHowLongBox stopButtonType description =
    case stopButtonType of
        Just stopButton ->
            div []
                [ div [ class "h3" ] [ text description ]
                , div []
                    [ button [ class "btn btn-primary", onClick (SubmitStopEvent stopButton 1) ] [ text "1 Hour" ]
                    , button [ class "btn btn-primary", onClick (SubmitStopEvent stopButton 2) ] [ text "2 Hours" ]
                    , button [ class "btn btn-primary", onClick (SubmitStopEvent stopButton -1) ] [ text "Forever" ]
                    , button [ class "btn bg-gray", onClick CloseForHowLongModal ] [ text "Cancel" ]
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
        [ class "h6 mr1"
        ]
        [ input [ type' "checkbox", onClick msg, checked isChecked ] []
        , text name
        ]


sampleList : List Sample -> Time -> String -> Html Msg
sampleList samples time playing =
    div [ class "p2" ]
        [ table []
            [ div [ class "h2" ] [ text "Track List" ]
            , tbody [] (List.map (sampleRow time playing) samples)
            ]
        ]


sampleRow : Time -> String -> Sample -> Html Msg
sampleRow time playing sample =
    let
        recognized_song =
            sample.metadata.recognized_song

        name =
            case recognized_song of
                Just a ->
                    Maybe.withDefault "" (List.head a.artists) ++ " - " ++ a.title

                Nothing ->
                    "Unknown Title"

        strikeThrough =
            if sample.metadata.hidden then
                style [ ( "text-decoration", "line-through" ) ]
            else
                style []
    in
        tr []
            [ td [ strikeThrough ] [ text name ]
            , td [ strikeThrough ] [ text (humanizeTime time sample.date) ]
            , td [] [ playButton playing sample.link ]
            , td [] [ toggleSampleVisibility sample ]
            ]


toggleSampleVisibility : Sample -> Html Msg
toggleSampleVisibility sample =
    let
        hidden =
            sample.metadata.hidden

        msg =
            if hidden then
                "Show"
            else
                "Hide"

        color =
            if hidden then
                "bg-green"
            else
                "bg-red"
    in
        button
            [ class ("btn btn-small " ++ color)
            , onClick (ToggleSampleVisibility sample.link)
            ]
            [ text msg ]


playButton : String -> String -> Html Msg
playButton playing link =
    if playing == link then
        button [ class "btn btn-small bg-blue", onClick (Stop) ] [ text "stop" ]
    else
        button [ class "btn btn-small bg-blue", onClick (Play link) ] [ text "play" ]


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
        "About " ++ toString (secondDiff // 3600) ++ " hours ago"
    else if secondDiff < 172800 then
        "Yesterday"
    else
        (toString (secondDiff // 86400)) ++ " days ago"


humanizeTime : Time -> String -> String
humanizeTime currentTime sampleTime =
    let
        r =
            Date.fromString sampleTime
    in
        case r of
            Result.Ok d ->
                toTimeAgo ((currentTime / 1000) - ((Date.toTime d) / 1000))

            Result.Err e ->
                toString e
