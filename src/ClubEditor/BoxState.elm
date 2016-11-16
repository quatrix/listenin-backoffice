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
            drawBoxState state timeNow
        Nothing ->
            div[][text "Getting box status..."]

drawBoxState : BoxState -> Time -> Html Msg
drawBoxState state timeNow =
    case state.blink of
        Just blink ->
            if blink.time > 100 then
                div[class "p1"] 
                [ somethingFresh timeNow state.color drawLED drawStaleLED drawMissingLED
                , somethingFresh timeNow state.status drawStatus drawStaleStatus drawMissingStatus
                ]
            else
                div[class "p1"] [ text "last time we heard from box was way ago"]
        Nothing ->
            div[class "p1"] [text "Last blink unknown"]


somethingFresh : Time -> Maybe BoxStateValue -> (BoxStateValue -> Html Msg) -> (Time -> BoxStateValue -> Html Msg) -> (Html Msg) -> Html Msg
somethingFresh timeNow v onValid onStale onMissing =
    case v of
        Just value -> 

            if (timeNow - toFloat(value.time)) > 2 then 
                onStale timeNow value
            else
                onValid value
        Nothing -> 
            onMissing


drawLED : BoxStateValue -> Html Msg
drawLED v =
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
    , text ("last led color was " ++ (toTimeAgo (timeNow - (toFloat v.time))))
    ]

drawMissingLED : Html Msg 
drawMissingLED =
    div[] [text "led missing"]



drawStatus : BoxStateValue -> Html Msg
drawStatus v =
    div[] [text v.value]
    
drawStaleStatus : Time -> BoxStateValue -> Html Msg 
drawStaleStatus timeNow t =
    div[] [text "status stale"]
        

drawMissingStatus : Html Msg 
drawMissingStatus =
    div[] [text "status missing"]

