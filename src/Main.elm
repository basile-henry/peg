module Main exposing (main)

import Board exposing (..)
import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (..)
import Html exposing (Html, beginnerProgram)
import List exposing (concat, repeat)
import StyleSheet exposing (..)
import Types exposing (..)


type alias Model =
    { boardType : BoardType
    , board : Board.Model
    , dropDownVisible : Bool
    }


model : Model
model =
    { boardType = French
    , board = Board.init boardWidth frenchBoard
    , dropDownVisible = False
    }


boardWidth : Float
boardWidth =
    700


type BoardType
    = French
    | German
    | Asymmetrical
    | English
    | Diamond


getBoard : BoardType -> Board
getBoard boardType =
    case boardType of
        French ->
            frenchBoard

        German ->
            germanBoard

        Asymmetrical ->
            asymmetricalBoard

        English ->
            englishBoard

        Diamond ->
            diamondBoard


type Msg
    = BoardMsg Board.Msg
    | DoRestart
    | DropDownToggle
    | PickBoard BoardType


main : Program Never Model Msg
main =
    beginnerProgram
        { model = model
        , update = update
        , view = view
        }


update : Msg -> Model -> Model
update msg model =
    case msg of
        BoardMsg msg_ ->
            { model
                | board = Board.update msg_ model.board
            }

        DoRestart ->
            { model
                | board = Board.init boardWidth <| getBoard model.boardType
            }

        DropDownToggle ->
            { model
                | dropDownVisible = not model.dropDownVisible
            }

        PickBoard board ->
            { model
                | board = Board.init boardWidth <| getBoard board
                , boardType = board
            }


view : Model -> Html Msg
view model =
    let
        spacer =
            el None [ height (px 30) ] empty

        rowSpacer =
            el None buttonAttrs empty

        buttons =
            row None [ width fill ] [ boardSelection model, rowSpacer, restart ]
    in
    column
        None
        [ padding 20, width (px (boardWidth + 40)) ]
        [ title
        , spacer
        , buttons
        , spacer
        , Element.map BoardMsg <| Board.view model.board
        ]
        |> el Body [ center, height fill ]
        |> layout styleSheet


title : Element Styles variation msg
title =
    el Title [ width fill ] (text "Peg Solitaire")


buttonAttrs : List (Attribute variation msg)
buttonAttrs =
    [ padding 5, width <| fillPortion 1 ]


boardSelection : Model -> Element Styles variation Msg
boardSelection model =
    let
        selection board str =
            el DropDown [ onClick (PickBoard board), padding 5 ] (text str)

        arrow =
            if model.dropDownVisible then
                "⇡"
            else
                "⇣"
    in
    text ("Board type " ++ arrow)
        |> el DropDown (onClick DropDownToggle :: buttonAttrs)
        |> below
            (if model.dropDownVisible then
                [ column
                    None
                    [ paddingTop 10, spacing 2 ]
                    [ selection French "French"
                    , selection German "German"
                    , selection English "English"
                    , selection Asymmetrical "Asymmetrical"
                    , selection Diamond "Diamond"
                    ]
                ]
             else
                []
            )


restart : Element Styles variation Msg
restart =
    el Restart (onClick DoRestart :: buttonAttrs) (text "Restart")
