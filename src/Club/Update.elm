port module Club.Update exposing (..)

import Club.Messages exposing (Msg(..))
import Club.Models exposing (Club)
import String

port play : String -> Cmd msg
port stop : String -> Cmd msg

update : Msg -> Club -> ( Club, Cmd Msg )
update message model =
    case message of
        FetchDone club ->
            ( club, Cmd.none )
        FetchFailed error ->
            ( model, Cmd.none )
        Play url ->
            ( { model | playing = url }, play url)
        Stop ->
            ( { model | playing = "" }, stop "")
        Delete sample ->
            ( model, Cmd.none )
        DescriptionChanged description ->
            ( { model | details = description }, Cmd.none )
        ToggleTag tag->
            ( { model | tags = (toggleTag model.tags tag)}, Cmd.none )
        Save ->
            ( model, Cmd.none )
        AskForHowLong buttonType ->
            ( { model | showForHowLongBox = True}, Cmd.none )



toggleTag : List String -> String -> List String
toggleTag tags tag =
    if isIn tag tags then
        List.filter (\x -> (String.toLower x) /= (String.toLower tag)) tags
    else
        List.append tags [tag]

isIn : String -> List String -> Bool
isIn niddle hay =
    not (List.isEmpty (List.filter (\x -> (String.toLower x) == (String.toLower niddle)) hay))

