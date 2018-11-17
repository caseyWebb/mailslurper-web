module Main exposing (main)

import Browser exposing (Document)
import Element exposing (Element)
import Html exposing (Html)
import Http
import Mail exposing (Mail)
import Mail.Address exposing (MailAddress)


main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type Model
    = Loading
    | Failure Problem
    | Ready ReadyModel


type Problem
    = ServerProblem Http.Error



-- type Width
--     = Fill
--     | Percent Int


type alias Column =
    { title : String
    , width : Int
    , visible : Bool
    , getValue : Mail -> String
    }


type alias ReadyModel =
    { mail : List Mail
    , selectedMail : Maybe Mail
    , columns : List Column

    -- , dateColumnWidth : Width
    -- , fromColumnWidth : Width
    -- , subjectColumnWidth : Width
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Mail.fetchAll MailLoaded
    )


columns : List Column
columns =
    [ { title = "Date"
      , width = 20
      , visible = True
      , getValue = \m -> m.dateSent
      }
    , { title = "From"
      , width = 20
      , visible = True
      , getValue = \m -> Mail.Address.toString m.fromAddress
      }
    , { title = "Subject"
      , width = 60
      , visible = True
      , getValue = \m -> m.subject
      }
    ]


initReadyModel : List Mail -> ReadyModel
initReadyModel mail =
    { mail = mail
    , selectedMail = Nothing
    , columns = columns
    }



-- readyModel mail =
-- UPDATE
-- model |


type Msg
    = MailLoaded (Result Http.Error (List Mail))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MailLoaded result ->
            case result of
                Ok mail ->
                    ( Ready (initReadyModel mail), Cmd.none )

                Err err ->
                    ( Failure (ServerProblem err), Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : Model -> Document msg
view model =
    case model of
        Loading ->
            viewLoading

        Failure err ->
            viewError err

        Ready m ->
            viewReady m


viewLoading : Document msg
viewLoading =
    { title = "Loading..."
    , body = [ Html.text "Loading..." ]
    }


viewError : Problem -> Document msg
viewError err =
    { title = "Error!"
    , body =
        [ Html.code [] [ Html.text (getErrorText err) ]
        ]
    }


viewReady : ReadyModel -> Document msg
viewReady model =
    { title = "mailslurper-web (@TODO count)"
    , body =
        [ Element.layout
            [ Element.padding 20
            , Element.width Element.fill
            ]
            (Element.row
                [ Element.width Element.fill ]
                [ leftSidebar model ]
            )
        ]
    }


columnSizing : Column -> Element.Attribute msg
columnSizing c =
    Element.width (Element.fillPortion c.width)


leftSidebar : ReadyModel -> Element msg
leftSidebar model =
    Element.column [ Element.width Element.fill ]
        [ mailListHeadings model
        , Element.row [ Element.width Element.fill ] (List.map createMailListItem model.mail)
        ]


mailListHeadings : ReadyModel -> Element msg
mailListHeadings model =
    Element.row [ Element.width Element.fill ]
        (List.map
            (\c -> Element.column [ columnSizing c ] [ Element.text c.title ])
            model.columns
        )


createMailListItem : Mail -> Element msg
createMailListItem mail =
    Element.row [ Element.width Element.fill ]
        (List.map
            (\c -> Element.column [ columnSizing c ] [ Element.text (c.getValue mail) ])
            columns
        )


getErrorText : Problem -> String
getErrorText problem =
    case problem of
        ServerProblem err ->
            case err of
                Http.BadUrl m ->
                    "Invalid API URL"

                Http.Timeout ->
                    "Network Timeout"

                Http.BadStatus status ->
                    "Bad Status: " ++ String.fromInt status

                Http.BadBody string ->
                    "Bad Body: " ++ string

                Http.NetworkError ->
                    "Network Error"
