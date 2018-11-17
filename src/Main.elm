module Main exposing (main)

import Browser exposing (Document)
import Element exposing (Element)
import Element.Background
import Html exposing (Html)
import Http
import List.MapParity
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



-- UPDATE


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
            (Element.column
                [ Element.width Element.fill ]
                [ leftSidebar model
                , Element.el [ Element.width Element.fill ] (Element.text "Foobar")
                ]
            )
        ]
    }


columnSizing : Column -> Element.Attribute msg
columnSizing c =
    Element.width (Element.fillPortion c.width)


leftSidebar : ReadyModel -> Element msg
leftSidebar model =
    Element.column [ Element.width Element.fill ]
        [ createColumnHeadings model.columns
        , createMailList model.mail
        ]


createColumnHeadings : List Column -> Element msg
createColumnHeadings cs =
    Element.row [ Element.width Element.fill ]
        (List.map
            (\c -> Element.column [ columnSizing c ] [ Element.text c.title ])
            cs
        )


createMailList : List Mail -> Element msg
createMailList mail =
    Element.column
        [ Element.width Element.fill ]
        (List.MapParity.mapParity createMailListItem mail)


createMailListItem : Mail -> List.MapParity.Parity -> Element msg
createMailListItem mail parity =
    Element.row
        [ Element.width Element.fill
        , getAlternatingBackground parity
        ]
        (List.map
            (\c -> Element.column [ columnSizing c ] [ Element.text (c.getValue mail) ])
            columns
        )


getAlternatingBackground : List.MapParity.Parity -> Element.Attribute a
getAlternatingBackground parity =
    case parity of
        List.MapParity.Odd ->
            Element.Background.color (Element.rgb255 200 200 200)

        List.MapParity.Even ->
            Element.Background.color (Element.rgb255 255 255 255)


getErrorText : Problem -> String
getErrorText problem =
    case problem of
        ServerProblem err ->
            getServerErrorText err


getServerErrorText : Http.Error -> String
getServerErrorText err =
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
