module Mail.Address exposing (MailAddress, decoder, encode, toString)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)

type MailAddress
 = MailAddress String

encode : MailAddress -> Value
encode (MailAddress str) =
  Encode.string str

decoder : Decoder MailAddress
decoder =
  Decode.map MailAddress Decode.string

toString : MailAddress -> String
toString (MailAddress str) =
  str