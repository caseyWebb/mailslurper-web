module Mail.Sort exposing (SortBy(..), SortOrder(..), sort)

import Mail exposing (Mail)
import Mail.Address


type SortBy
    = DateSent
    | FromAddress
    | Subject


type SortOrder
    = Ascending
    | Descending


sort : SortBy -> SortOrder -> List Mail -> List Mail
sort by order mail =
    let
        sorted =
            List.sortBy (sortPropAccessor by) mail
    in
    case order of
        Ascending ->
            sorted

        Descending ->
            List.reverse sorted


sortPropAccessor : SortBy -> Mail -> String
sortPropAccessor by m =
    case by of
        DateSent ->
            m.dateSent

        FromAddress ->
            Mail.Address.toString m.fromAddress

        Subject ->
            m.subject
