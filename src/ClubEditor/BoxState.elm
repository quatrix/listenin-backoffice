module ClubEditor.BoxState exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class)
import Time exposing (Time)
import Models exposing (BoxState, BoxStateValue)
import ClubEditor.Messages exposing (..)
import ClubEditor.Utils exposing (toTimeAgo)

currentBoxState : Maybe BoxState -> Time -> Html Msg
currentBoxState boxState timeNow =
    case boxState of
        Just state ->
            div [class "p1 border bg-silver" ] 
            [ div[ class "h5" ] [text "Box state:"]
            , drawBoxState state timeNow
            ]
        Nothing ->
            div[class "p1"][text "Getting box status..."]

drawBoxState : BoxState -> Time -> Html Msg
drawBoxState state timeNow =
    case state.blink of
        Just blink ->
            let
                td = (timeNow - (toFloat blink.time))
            in
                if td > 60 * 10 then
                    div[class "p1"] [ text ("Last box event was " ++ (toTimeAgo td))]
                else
                    div[class "p1"] 
                    [ somethingFresh timeNow state.status drawStatus drawStaleStatus drawMissingStatus
                    , somethingFresh timeNow state.color drawLED drawStaleLED drawMissingLED
                    , drawBlink timeNow blink
                    ]
        Nothing ->
            div[class "p1"] [text "Last blink unknown"]


drawBlink : Time -> BoxStateValue -> Html Msg
drawBlink timeNow blink =
    div []
    [ div [class "h5"][ text ("last keep-alive " ++ (toTimeAgo (timeNow - (toFloat blink.time))))]]


somethingFresh : Time -> Maybe BoxStateValue -> (Time -> BoxStateValue -> Html Msg) -> (Time -> BoxStateValue -> Html Msg) -> (Html Msg) -> Html Msg
somethingFresh timeNow v onValid onStale onMissing =
    case v of
        Just value -> 
            if (timeNow - toFloat(value.time)) > 60 * 5 then 
                onStale timeNow value
            else
                onValid timeNow value
        Nothing -> 
            onMissing


drawLED : Time -> BoxStateValue -> Html Msg
drawLED timeNow v =
    div[class "flex items-center h3"] 
    [ i[class ("fa mr1 fa-circle " ++ v.value)] []
    , text (ledColorToMeaning v.value)
    ]

ledColorToMeaning : String -> String 
ledColorToMeaning color =
    case color of
        "red" -> "Recording"
        "orange" -> "Problem, Retrying"
        "blue" -> "Uploading"
        "green" -> "A-OK"
        "purple" -> "Waiting for signal"
        _ -> "Unknown"

    
drawStaleLED : Time -> BoxStateValue -> Html Msg 
drawStaleLED timeNow v =
    div[class "flex items-center h3"] 
    [ i[class ("fa mr1 fa-circle gray")] []
    , text ("last state change was " ++ (toTimeAgo (timeNow - (toFloat v.time))))
    ]


drawMissingLED : Html Msg 
drawMissingLED =
    div[class "flex items-center h3"] 
    [ i[class ("fa mr1 fa-circle gray")] []
    , text ("box state unknown")
    ]


drawStatus : Time -> BoxStateValue -> Html Msg
drawStatus timeNow v =
    let
        td = timeNow - (toFloat v.time)
    in
        div[]
        [ i[class "h3"] [text v.value]
        , i[class "ml1 h6"] [text ("(" ++ (toTimeAgo td) ++ ")")]
        ]
    
drawStaleStatus : Time -> BoxStateValue -> Html Msg 
drawStaleStatus timeNow v =
    let
        td = timeNow - (toFloat v.time)
    in
        i[class "h3"] [text ("Last known box state was " ++ (toTimeAgo td))]
        

drawMissingStatus : Html Msg 
drawMissingStatus =
    i[class "h3"] [text "Box state unknown"]

