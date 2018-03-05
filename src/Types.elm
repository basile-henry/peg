module Types exposing (..)


type Cell
    = Empty -- Empty cell part of the board
    | Peg -- Cell containing a peg
    | Outside -- Cell not part of the board (invisible)


type alias Board =
    List (List Cell)
