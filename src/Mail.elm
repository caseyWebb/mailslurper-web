module Mail exposing (Mail, fetchAll)

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required, optional)

import Api
import Api.Endpoint as Endpoints
import Mail.Id exposing (MailId)
import Mail.Address exposing (MailAddress)

-- TYPES


type alias Mail =
 { id: MailId
 , fromAddress: MailAddress
 , toAddresses: List MailAddress
 , subject: String
 , body: String
 }

type Msg
  = MailLoaded (Result Http.Error (List Mail))

-- SERIALIZATION

mailDecoder : Decoder Mail
mailDecoder =
  Decode.succeed Mail
    |> required "id" Mail.Id.decoder
    |> required "fromAddress" Mail.Address.decoder
    |> required "toAddresses" (Decode.list Mail.Address.decoder)
    |> optional "subject" Decode.string ""
    |> optional "body" Decode.string ""


mailListDecoder : Decoder (List Mail)
mailListDecoder = Decode.field "mailItems" (Decode.list mailDecoder)

-- LIST

fetchAll : (Result Http.Error (List Mail) -> msg) -> Cmd msg
fetchAll = Api.get Endpoints.mail mailListDecoder

