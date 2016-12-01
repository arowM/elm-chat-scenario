port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Html.CssHelpers exposing (withNamespace)
import Scenario.ChatUI.Css as ChatUI


port files : CssFileStructure -> Cmd msg


mynamespace : Html.CssHelpers.Namespace String class id msg
mynamespace =
    withNamespace "homepage"


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "homepage.css", Css.File.compile [ ChatUI.css mynamespace ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
