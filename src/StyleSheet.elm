module StyleSheet exposing (..)

import Color exposing (..)
import Style exposing (..)
import Style.Border exposing (none)
import Style.Color exposing (..)
import Style.Font exposing (..)
import Types exposing (..)


type Styles
    = Body
    | Title
    | DropDown
    | Restart
    | BoardStyle
    | CellStyle Cell
    | DropHighlight
    | None


buttonStyle : Styles -> Color -> Style Styles variation
buttonStyle class color =
    style class
        [ Style.Color.text white
        , size 25
        , background color
        , center
        , Style.cursor "pointer"
        ]


styleSheet : StyleSheet Styles variation
styleSheet =
    Style.styleSheet
        [ style Body [ typeface [ font "Calibri", sansSerif ] ]
        , style Title
            [ Style.Color.text charcoal
            , size 50
            ]
        , buttonStyle DropDown blue
        , buttonStyle Restart orange
        , style BoardStyle []
        , style DropHighlight [ background blue ]
        , style (CellStyle Empty) [ background grey ]
        , style (CellStyle Peg) [ background green ]
        , style None []
        ]
