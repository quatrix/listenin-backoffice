module ClubEditor.Utils exposing (..)
import Time exposing (Time)
import Date

toTimeAgo : Time -> String
toTimeAgo secondDiff =
    if secondDiff < 60 then
        (toString (round secondDiff)) ++ " seconds ago"
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
                toTimeAgo (currentTime - ((Date.toTime d) / 1000))

            Result.Err e ->
                toString e
