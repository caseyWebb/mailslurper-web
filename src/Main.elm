module Main exposing (main)

import Browser exposing (Document)
import Element exposing (Element)
import Element.Background
import Element.Events
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


type ReadyState
    = Loading
    | Failure Problem
    | Ready Model


type Problem
    = ServerProblem Http.Error


type alias Column =
    { title : String
    , width : Int
    , visible : Bool
    , getValue : Mail -> String
    }


type alias Model =
    { mail : List Mail
    , selectedMail : Maybe Mail
    , columns : List Column
    }


init : () -> ( ReadyState, Cmd Msg )
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


initReadyModel : List Mail -> Model
initReadyModel mail =
    { mail = mail
    , selectedMail = Nothing
    , columns = columns
    }



-- UPDATE


type Msg
    = MailLoaded (Result Http.Error (List Mail))
    | SelectMail Mail


update : Msg -> ReadyState -> ( ReadyState, Cmd Msg )
update msg readyState =
    let
        model =
            case readyState of
                Loading ->
                    initReadyModel []

                Failure _ ->
                    initReadyModel []

                Ready m ->
                    m
    in
    case msg of
        MailLoaded result ->
            case result of
                Ok mail ->
                    ( Ready (initReadyModel mail), Cmd.none )

                Err err ->
                    ( Failure (ServerProblem err), Cmd.none )

        SelectMail mail ->
            ( Ready { model | selectedMail = Just mail }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : ReadyState -> Sub Msg
subscriptions model =
    Sub.none



-- VIEW


view : ReadyState -> Document Msg
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


viewReady : Model -> Document Msg
viewReady model =
    { title = "mailslurper-web (@TODO count)"
    , body =
        [ Element.layout
            [ Element.padding 20
            , Element.width Element.fill
            ]
            (Element.row
                []
                [ Element.column
                    [ Element.width Element.fill ]
                    [ createMailList model ]
                , Element.column
                    [ Element.width Element.fill ]
                    [ createMailPreview model.selectedMail ]
                ]
            )
        ]
    }


columnSizing : Column -> Element.Attribute Msg
columnSizing c =
    Element.width (Element.fillPortion c.width)


createMailList : Model -> Element Msg
createMailList model =
    Element.column [ Element.width Element.fill ]
        [ createColumnHeadings model.columns
        , Element.column
            [ Element.width Element.fill ]
            (List.MapParity.mapParity createMailListItem model.mail)
        ]


createColumnHeadings : List Column -> Element Msg
createColumnHeadings cs =
    Element.row [ Element.width Element.fill ]
        (List.map
            (\c -> Element.column [ columnSizing c ] [ Element.text c.title ])
            cs
        )


createMailListItem : Mail -> List.MapParity.Parity -> Element Msg
createMailListItem mail parity =
    Element.row
        [ Element.width Element.fill
        , getAlternatingBackground parity
        , highlightOnHover
        , Element.Events.onClick (SelectMail mail)
        ]
        (List.map
            (\c -> Element.column [ columnSizing c ] [ Element.text (c.getValue mail) ])
            columns
        )


createMailPreview : Maybe Mail -> Element Msg
createMailPreview maybeSelectedMail =
    case maybeSelectedMail of
        Just mail ->
            Element.el [] (Element.text mail.body)

        Nothing ->
            Element.el [] (Element.text "Select a message from the left")


highlightOnHover : Element.Attribute a
highlightOnHover =
    Element.mouseOver
        [ Element.Background.color (Element.rgb255 100 100 100)
        ]


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
