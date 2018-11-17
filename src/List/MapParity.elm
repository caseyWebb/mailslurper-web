module List.MapParity exposing (Parity(..), mapParity)

import List


type Parity
    = Odd
    | Even


mapParity : (a -> Parity -> b) -> List a -> List b
mapParity fn list =
    case list of
        odd :: (even :: rest) ->
            List.concat
                [ [ fn odd Odd
                  , fn even Even
                  ]
                , mapParity fn rest
                ]

        odd :: _ ->
            [ fn odd Odd ]

        [] ->
            []
