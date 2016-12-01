port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import Scenario.Styles.ChatUI as ChatUI


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "homepage.css", Css.File.compile [ ChatUI.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
