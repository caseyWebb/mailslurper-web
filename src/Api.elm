module Api exposing (get)

import Http exposing (..)
import Json.Decode exposing (Decoder)

import Api.Endpoint exposing (Endpoint)



-- HTTP

get : Endpoint -> Decoder a -> (Result Error a -> msg) -> Cmd msg
get url decoder msg =
  Http.get
    { url = Api.Endpoint.unwrap url
    , expect = Http.expectJson msg decoder }
