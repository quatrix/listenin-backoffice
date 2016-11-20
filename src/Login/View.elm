module Login.View exposing (..)
import Html exposing (..)
import Html.Attributes exposing (class, style, placeholder, type')
import Html.Events exposing (..)
import Json.Decode as Json


import Login.Messages exposing (Msg(..))
import Login.Models exposing (Login)


view : Maybe Login -> Html Msg
view model =
    div
        [ class "absolute flex justify-center items-center bg-gray"
        , style [("height", "100%"), ("width", "100%")] 
        ]
        [ div[class "bg-silver border p1"] 
            [ div[class "h1"][text "ListenIn"]
            , div[] [ input 
                        [ type' "text"
                        , placeholder "Username"
                        , onInput Username
                        , onEnter Submit
                        ] [] 
                    ]
            , div [] [ input 
                        [ type' "password"
                        , placeholder "Password"
                        , onInput Password
                        , onEnter Submit
                    ] [] ]
            , div [] [ button [ class "btn btn-outline my1", onClick Submit ] [text "Login"] ]
            , msgBox model
            ]
        ]

msgBox : Maybe Login -> Html Msg
msgBox login =
    case login of
        Just l ->
            if l.waiting then
                div[] [i[class "fa fa-cog fa-x1 fa-spin mr1"][], text "loading..."]
            else            
                case l.error of
                    Just error ->
                        div[] [i[class "fa fa-times red mr1"][], text error]
                    Nothing ->
                        div[][]
        Nothing ->
            div[][]


onEnter : Msg -> Attribute Msg
onEnter msg =
    let
        isEnter code =
            if code == 13 then
                Json.succeed msg
            else
                Json.fail "not ENTER"
    in
        on "keydown" (Json.andThen keyCode isEnter)
