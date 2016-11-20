module ClubEditor.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style, class, controls, type', src, id, checked, rows)
import Html.App
import Html.Events exposing (onClick, onInput)
import ClubEditor.Models exposing (..)
import ClubEditor.Update exposing (isIn)
import ClubEditor.Messages exposing (..)
import ClubEditor.BoxState exposing (currentBoxState)
import ClubEditor.Utils exposing (humanizeTime)
import Models exposing (BoxState)
import Messages
import Time exposing (Time)
import Date
import Date.Extra.Duration as Duration
import String


view : ClubEditor -> Time -> Maybe BoxState -> Html Msg
view clubEditor time boxState =
    let
        club =
            clubEditor.club
    in
        div [ class "clearfix" ]
            [ systemMessage clubEditor.systemMessage
            , header club
            , clubEditWindow clubEditor.isClubEditWindowVisible club
            , div[ class "p1"] [currentBoxState boxState time]
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
                div [ style [("margin-left", "300px")], class ("flex absolute " ++ (getMessageClassByType systemMessage.msgType)) ]
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
    div [ class "flex p1 justify-between" ]
        [ div [class "h1 flex", style [("font-family", "Lato")]]
          [ img [ class "mr1", src club.logo.xxxhdpi, style [ ( "width", "50px" ), ( "height", "50px" ) ] ] []
          , text (String.toUpper club.name)
          ]
        , button [ class "btn h2 bg-yellow", onClick OpenClubEditWindow ] [ i [ class "fa fa-info-circle" ] []]
        ]


clubEditWindow : Bool -> Club -> Html Msg
clubEditWindow visible club =
    if visible then
        div []
            [ div [ class "p2" ]
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
                , div [class "my1"]
                    [ button [ class "btn btn-primary mr1", onClick Save ] [ text "Save" ]
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
        div [class "p1 "]
            [ div [class "flex justify-between"] 
                [ stopButton timeNow club.stopPublishing StopPublishing "fa-low-vision" publishing
                 , stopButton timeNow club.stopRecording StopRecording "fa-circle" recording
                 , stopButton timeNow club.stopRecognition StopRecognition "fa-headphones" recognition
                ] 
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
                [ div [ class "p1" ] [ text description ]
                , div [ class "p1" ]
                    [ button [ class "btn btn-primary mr1", onClick (SubmitStopEvent stopButton 1) ] [ text "1 Hour" ]
                    , button [ class "btn btn-primary mr1", onClick (SubmitStopEvent stopButton 2) ] [ text "2 Hours" ]
                    , button [ class "btn btn-primary mr1", onClick (SubmitStopEvent stopButton -1) ] [ text "Forever" ]
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
    div [ class "p1" ]
        [ div [ class "h2" ] [ text "Track List" ]
        , table [class "table", style [("width", "100%")]] [ tbody [] (List.map (sampleRow time playing) samples) ]
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
            if sample.metadata.keep_unrecognized then
                style [ ( "text-decoration", "line-through" ) ]
            else
                style []

        hidden =
            if sample.metadata.hidden then
                "fa-eye-slash red"
            else
                "fa-eye green"
    in
        tr []
            [ td [] [i[class ("fa " ++ hidden)][] ]
            , td [ strikeThrough ] [ text name ]
            , td [ ] [ text (humanizeTime time sample.date) ]
            , td [] [ playButton playing sample.link ]
            , td [] [ toggleSampleVisibility sample ]
            ]


toggleSampleVisibility : Sample -> Html Msg
toggleSampleVisibility sample =
    let
        hidden =
            sample.metadata.hidden

        icon =
            if hidden then
                "fa-undo"
            else
                "fa-trash"
    in
        button
            [ class "btn btn-small"
            , onClick (ToggleSampleVisibility sample.id)
            ]
            [ i [class ("fa " ++ icon)][]]


playButton : String -> String -> Html Msg
playButton playing link =
    if playing == link then
        button [ class "btn btn-small", onClick (Stop) ] [ i [class "fa fa-stop"] [] ]
    else
        button [ class "btn btn-small", onClick (Play link) ] [ i [class "fa fa-play"] [] ]
