module Main exposing (main)

-- import Element.Attribute

import Browser exposing (Document)
import Element exposing (Element)
import Element.Background
import Element.Events
import FontAwesome
import Html exposing (Html)
import Http
import List.MapParity
import Mail exposing (Mail)
import Mail.Address exposing (MailAddress)
import Mail.Sort


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
    , sortBy : Mail.Sort.SortBy
    , getValue : Mail -> String
    }


type alias Model =
    { mail : List Mail
    , selectedMail : Maybe Mail
    , columns : List Column
    , sortBy : Mail.Sort.SortBy
    , sortOrder : Mail.Sort.SortOrder
    }


init : () -> ( ReadyState, Cmd Msg )
init _ =
    ( Loading
    , Mail.fetchAll MailLoaded
    )



-- UPDATE


type Msg
    = MailLoaded (Result Http.Error (List Mail))
    | SelectMail Mail
    | ToggleSort Mail.Sort.SortBy


update : Msg -> ReadyState -> ( ReadyState, Cmd Msg )
update msg readyState =
    let
        defaults =
            { mail = []
            , selectedMail = Nothing
            , sortBy = Mail.Sort.DateSent
            , sortOrder = Mail.Sort.Ascending
            , columns =
                [ { title = "Date"
                  , width = 20
                  , visible = True
                  , sortBy = Mail.Sort.DateSent
                  , getValue = \m -> m.dateSent
                  }
                , { title = "From"
                  , width = 20
                  , visible = True
                  , sortBy = Mail.Sort.FromAddress
                  , getValue = \m -> Mail.Address.toString m.fromAddress
                  }
                , { title = "Subject"
                  , width = 60
                  , visible = True
                  , sortBy = Mail.Sort.Subject
                  , getValue = \m -> m.subject
                  }
                ]
            }

        model =
            case readyState of
                Loading ->
                    defaults

                Failure _ ->
                    defaults

                Ready m ->
                    m
    in
    case msg of
        MailLoaded result ->
            case result of
                Ok mail ->
                    ( Ready { model | mail = mail }, Cmd.none )

                Err err ->
                    ( Failure (ServerProblem err), Cmd.none )

        SelectMail mail ->
            ( Ready { model | selectedMail = Just mail }, Cmd.none )

        ToggleSort sortBy ->
            let
                sortOrder =
                    if sortBy /= model.sortBy then
                        model.sortOrder

                    else
                        case model.sortOrder of
                            Mail.Sort.Ascending ->
                                Mail.Sort.Descending

                            Mail.Sort.Descending ->
                                Mail.Sort.Ascending
            in
            ( Ready { model | sortBy = sortBy, sortOrder = sortOrder }, Cmd.none )



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
    let
        sortedMail =
            Mail.Sort.sort model.sortBy model.sortOrder model.mail
    in
    Element.column [ Element.width Element.fill ]
        [ createColumnHeadings model
        , Element.column
            [ Element.width Element.fill ]
            (List.MapParity.mapParity (createMailListItem model) sortedMail)
        ]


createColumnHeadings : Model -> Element Msg
createColumnHeadings model =
    Element.row [ Element.width Element.fill ]
        (model.columns
            |> List.map
                (\c ->
                    Element.column
                        [ columnSizing c
                        , Element.Events.onClick (ToggleSort c.sortBy)
                        ]
                        [ Element.text c.title
                        , Element.el [ Element.alignRight ] (getSortIndicator model c)
                        ]
                )
        )


getSortIndicator : Model -> Column -> Element.Element msg
getSortIndicator model column =
    if model.sortBy == column.sortBy then
        FontAwesome.caret
            (if model.sortOrder == Mail.Sort.Ascending then
                FontAwesome.Up

             else
                FontAwesome.Down
            )

    else
        Element.none


createMailListItem : Model -> Mail -> List.MapParity.Parity -> Element Msg
createMailListItem model mail parity =
    Element.row
        (List.concat
            [ [ Element.width Element.fill
              , Element.Events.onClick (SelectMail mail)
              ]
            , getBackgroundStyles model mail parity
            ]
        )
        (List.map
            (\c -> Element.column [ columnSizing c ] [ Element.text (c.getValue mail) ])
            model.columns
        )


createMailPreview : Maybe Mail -> Element Msg
createMailPreview maybeSelectedMail =
    case maybeSelectedMail of
        Just mail ->
            Element.el [] (Element.text mail.body)

        Nothing ->
            Element.el [] (Element.text "Select a message from the left")


getBackgroundStyles : Model -> Mail -> List.MapParity.Parity -> List (Element.Attribute a)
getBackgroundStyles model mail parity =
    let
        defaultBackground =
            [ Element.mouseOver
                [ Element.Background.color (Element.rgb255 100 100 100)
                ]
            , case parity of
                List.MapParity.Odd ->
                    Element.Background.color (Element.rgb255 200 200 200)

                List.MapParity.Even ->
                    Element.Background.color (Element.rgb255 255 255 255)
            ]
    in
    case model.selectedMail of
        Nothing ->
            defaultBackground

        Just selectedMail ->
            if selectedMail == mail then
                [ Element.Background.color (Element.rgb255 50 50 50) ]

            else
                defaultBackground


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
