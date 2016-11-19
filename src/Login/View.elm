module Login.View exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, style, placeholder, type')
import Html.Events exposing (onInput, onClick)

import Login.Messages exposing (Msg(..))
import Login.Models exposing (Login)


view : Maybe Login -> Html Msg
view model =
    div[class "absolute flex justify-center items-center bg-gray", style [("height", "100%"), ("width", "100%")] ]
        [ div[class "bg-silver border p1"] 
            [ div[class "h1"][text "ListenIn"]
            , div[] [ input [ type' "text", placeholder "Name", onInput Username ] [] ]
            , div [] [ input [ type' "password", placeholder "Password", onInput Password ] [] ]
            , div [] [ button [ class "btn btn-outline my1", onClick Submit ] [text "Login"] ]
            ]
        ]
