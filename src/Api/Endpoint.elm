module Api.Endpoint exposing (Endpoint, unwrap, mail)

import Url.Builder exposing (QueryParameter)

-- TYPES

type Endpoint
  = Endpoint String

unwrap : Endpoint -> String
unwrap (Endpoint str) =
  str

url : List String -> List QueryParameter -> Endpoint
url paths queryParams =
  Url.Builder.crossOrigin "https://mail.caseywebb.xyz" -- @TODO make configurable
    ("api" :: paths)
    queryParams
    |> Endpoint


-- ENDPOINTS


mail : Endpoint
mail =
  url [ "mail" ] []