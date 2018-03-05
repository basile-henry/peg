module Board exposing (..)

import Element exposing (..)
import Element.Attributes exposing (..)
import Element.Events exposing (onMouseDown)
import Html exposing (Html, program)
import Html5.DragDrop as DragDrop
import List exposing (concat, repeat)
import List.Extra
import Maybe
import StyleSheet exposing (..)
import Types exposing (..)


frenchBoard : Board
frenchBoard =
    [ repeat 2 Outside ++ repeat 3 Peg ++ repeat 2 Outside
    , repeat 1 Outside ++ repeat 5 Peg ++ repeat 1 Outside
    , repeat 7 Peg
    , repeat 3 Peg ++ [ Empty ] ++ repeat 3 Peg
    , repeat 7 Peg
    , repeat 1 Outside ++ repeat 5 Peg ++ repeat 1 Outside
    , repeat 2 Outside ++ repeat 3 Peg ++ repeat 2 Outside
    ]


germanBoard : Board
germanBoard =
    [ repeat 3 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 3 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 3 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 9 Peg
    , repeat 4 Peg ++ [ Empty ] ++ repeat 4 Peg
    , repeat 9 Peg
    , repeat 3 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 3 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 3 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    ]


englishBoard : Board
englishBoard =
    [ repeat 2 Outside ++ repeat 3 Peg ++ repeat 2 Outside
    , repeat 2 Outside ++ repeat 3 Peg ++ repeat 2 Outside
    , repeat 7 Peg
    , repeat 3 Peg ++ [ Empty ] ++ repeat 3 Peg
    , repeat 7 Peg
    , repeat 2 Outside ++ repeat 3 Peg ++ repeat 2 Outside
    , repeat 2 Outside ++ repeat 3 Peg ++ repeat 2 Outside
    ]


asymmetricalBoard : Board
asymmetricalBoard =
    [ repeat 2 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 2 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 2 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 8 Peg
    , repeat 3 Peg ++ [ Empty ] ++ repeat 4 Peg
    , repeat 8 Peg
    , repeat 2 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 2 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    ]


diamondBoard : Board
diamondBoard =
    [ repeat 4 Outside ++ repeat 1 Peg ++ repeat 4 Outside
    , repeat 3 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 2 Outside ++ repeat 5 Peg ++ repeat 2 Outside
    , repeat 1 Outside ++ repeat 7 Peg ++ repeat 1 Outside
    , repeat 4 Peg ++ [ Empty ] ++ repeat 4 Peg
    , repeat 1 Outside ++ repeat 7 Peg ++ repeat 1 Outside
    , repeat 2 Outside ++ repeat 5 Peg ++ repeat 2 Outside
    , repeat 3 Outside ++ repeat 3 Peg ++ repeat 3 Outside
    , repeat 4 Outside ++ repeat 1 Peg ++ repeat 4 Outside
    ]


type alias Index =
    ( Int, Int )


type alias Model =
    { width : Float
    , board : Board
    , dragDrop : DragDrop.Model Index Index
    , lastDrag : Index
    }


init : Float -> Board -> Model
init width board =
    { width = width
    , board = board
    , dragDrop = DragDrop.init
    , lastDrag = ( 0, 0 )
    }


type Msg
    = DragDrop (DragDrop.Msg Index Index)
    | MouseDown Index


update : Msg -> Model -> Model
update msg model =
    case msg of
        DragDrop msg_ ->
            let
                ( dragDrop, result ) =
                    DragDrop.update msg_ model.dragDrop
            in
            { model
                | dragDrop = dragDrop
                , board =
                    case result of
                        Just ( drag, drop ) ->
                            if validDrop model.board drag drop then
                                let
                                    over =
                                        getOverIndex drag drop
                                            |> Maybe.withDefault ( 0, 0 )
                                in
                                model.board
                                    |> setAt drag Empty
                                    |> setAt over Empty
                                    |> setAt drop Peg
                            else
                                model.board

                        Nothing ->
                            model.board
            }

        MouseDown idx ->
            { model
                | lastDrag = idx
            }


view : Model -> Element Styles variation Msg
view model =
    column
        BoardStyle
        [ spread ]
        (List.indexedMap (viewRow model) model.board)


viewRow :
    Model
    -> Int
    -> List Cell
    -> Element Styles variation Msg
viewRow model y boardRow =
    row
        BoardStyle
        [ spread ]
        (List.indexedMap (viewCell model y) boardRow)


viewCell :
    Model
    -> Int
    -> Int
    -> Cell
    -> Element Styles variation Msg
viewCell model y x cell =
    let
        dropId =
            DragDrop.getDropId model.dragDrop

        position =
            ( x, y )

        isDrop =
            dropId == Just position

        isValidDrop =
            dropId
                |> Maybe.map (validDrop model.board model.lastDrag)
                |> Maybe.withDefault False
                |> (&&) isDrop

        peg r s =
            circle r s [ center, verticalCenter ] empty

        cellWidth =
            model.board
                |> List.head
                |> Maybe.map List.length
                |> Maybe.withDefault 1
                |> toFloat
                |> (/) model.width

        ( pegCell, attrs ) =
            case cell of
                Outside ->
                    ( empty, [] )

                Empty ->
                    ( peg
                        (cellWidth / 10)
                        (if isValidDrop then
                            DropHighlight
                         else
                            CellStyle Empty
                        )
                    , List.map toAttr <| DragDrop.droppable DragDrop position
                    )

                Peg ->
                    ( peg
                        (cellWidth / 3)
                        (CellStyle Peg)
                    , DragDrop.draggable DragDrop position
                        |> List.map toAttr
                        |> (::) (onMouseDown <| MouseDown position)
                    )
    in
    el None ([ width (px cellWidth), height (px cellWidth) ] ++ attrs) pegCell


getOverIndex : Index -> Index -> Maybe Index
getOverIndex ( a, b ) ( c, d ) =
    if a == c && abs (d - b) == 2 then
        Just ( a, b + sig (d - b) )
    else if b == d && abs (c - a) == 2 then
        Just ( a + sig (c - a), b )
    else
        Nothing


sig : Int -> Int
sig x =
    if x > 0 then
        1
    else
        -1


validDrop : Board -> Index -> Index -> Bool
validDrop board drag drop =
    let
        ( a, b ) =
            drag

        ( c, d ) =
            drop

        emptyDrop =
            getAt drop board == Empty

        skipOne =
            (a == c && abs (b - d) == 2)
                || (b == d && abs (a - c) == 2)

        overAPeg =
            (a == c && getAt ( a, b + sig (d - b) ) board == Peg)
                || (b == d && getAt ( a + sig (c - a), b ) board == Peg)
    in
    emptyDrop && skipOne && overAPeg


getAt : Index -> Board -> Cell
getAt ( x, y ) board =
    let
        getAtRow x cells =
            cells
                |> List.Extra.getAt x
                |> Maybe.withDefault Outside
    in
    board
        |> List.Extra.getAt y
        |> Maybe.map (getAtRow x)
        |> Maybe.withDefault Outside


setAt : Index -> Cell -> Board -> Board
setAt ( x, y ) cell board =
    List.Extra.updateAt y (List.Extra.setAt x cell) board
