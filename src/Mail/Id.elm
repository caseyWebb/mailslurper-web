module Mail.Id exposing (MailId, decoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)

type MailId
 = MailId String

encode : MailId -> Value
encode (MailId str) =
  Encode.string str

decoder : Decoder MailId
decoder =
  Decode.map MailId Decode.string