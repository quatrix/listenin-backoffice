module Club.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, controls, type', src, id)
import Html.App
import Html.Events exposing (onClick, onInput)
import Club.Models exposing (Club, Sample, SampleMetadataRecognized_song)
import Club.Messages exposing (..)
import Messages
import Time exposing (Time)
import Date

view : Club -> Time -> Html Msg
view club time =
    div [class "clearfix mb2 white bg-black"]
        [ div[class "h1"] [text club.name]
        , div[] [img [src club.logo.xxxhdpi][]]
        , div[] [textarea [onInput DescriptionChanged] [text club.details]]
        , div[] [text ("Tags: " ++ (toString club.tags))]
        , audio
            [ src "" 
            , id "audio-player"
            , type' "audio/mpeg" 
            , controls False
            ]
            []
        , sampleList club.samples time club.playing
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
        , td [] [ button [ onClick (Delete sample.date) ] [ text "delete"] ]
        ]

playButton : String -> String -> Html Msg
playButton playing link =
    if playing == link then
        button [ onClick (Stop) ] [ text "stop" ]
    else
        button [ onClick (Play link) ] [ text "play"]

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
