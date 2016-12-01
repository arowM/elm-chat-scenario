module SharedStyles exposing (..)

import Html.CssHelpers exposing (withNamespace)


type CssClasses
    = Container
    | Header
    | MessageArea
    | Balloon
    | IsInput
    | InputArea
    | SingleInput
    | SubmitButton


type CssIds
    = CssIds


homepageNamespace : Html.CssHelpers.Namespace String class id msg
homepageNamespace =
    withNamespace "homepage"
