module FontAwesome exposing (Orientation(..), caret)

import Element
import Element.Font
import Html.Attributes


type Orientation
    = Up
    | Down


caret : Orientation -> Element.Element msg
caret orientation =
    Element.el
        [ Element.Font.family [ Element.Font.typeface "FontAwesome" ]
        , Element.htmlAttribute
            (Html.Attributes.class
                (case orientation of
                    Up ->
                        "fa fa-caret-up"

                    Down ->
                        "fa fa-caret-down"
                )
            )
        ]
        Element.none
