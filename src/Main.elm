module Main exposing (main)

import Browser exposing (Document)
import Html exposing (..)
import Http
import Mail exposing (Mail)


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


type alias ReadyModel =
    { mail : List Mail
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Loading
    , Mail.fetchAll MailLoaded
    )



-- UPDATE


type Msg
    = MailLoaded (Result Http.Error (List Mail))


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MailLoaded result ->
            case result of
                Ok mail ->
                    ( Ready { mail = mail }, Cmd.none )

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
    , body =
        [ div []
            [ text "Loading..."
            ]
        ]
    }


viewError : Problem -> Document msg
viewError err =
    { title = "Error!"
    , body =
        [ div []
            [ text (getErrorText err)
            ]
        ]
    }


viewReady : ReadyModel -> Document msg
viewReady model =
    { title = "mailslurper-web (@TODO count)"
    , body =
        [ ul
            []
            (List.map createMailListItem model.mail)
        ]
    }


createMailListItem : Mail -> Html msg
createMailListItem mail =
    li [] [ text mail.subject ]


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
