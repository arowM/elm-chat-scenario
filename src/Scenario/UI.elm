module Scenario.UI exposing
  ( DefaultScenario
  , ReadValue
  , ImageSrc
  , Label
  , Name
  , PrintValue
  , printImage
  , printString
  , ReadArea
  , readSingleText
  , readPassword
  , readMultiLine
  , singleSelectPullDown
  , singleSelectButton
  , multiSelectPullDown
  , multiSelectButton
  , SelectOptions
  , emptySelectOptions
  , addSelectOption
  , Validation
  , validation
  , noValidation
  , Balloons
  , emptyBalloons
  , addUserBalloon
  , addSystemBalloon
  , Config
  , config
  , renderBalloons
  , renderPrintValue
  , renderReadArea
  , css
  )

{-| A set of functions for creating usual Conversational User Interface.

# Scenario

@docs DefaultScenario

# View

@docs renderBalloons
@docs renderPrintValue
@docs renderReadArea

# CSS

@docs css

# `Config`

@docs Config

@docs config

# `Balloons`

@docs Balloons

@docs emptyBalloons
@docs addUserBalloon
@docs addSystemBalloon

# `PrintValue`

@docs PrintValue

@docs printImage
@docs printString

# `ReadArea`

@docs ReadArea

@docs readSingleText
@docs readPassword
@docs readMultiLine
@docs singleSelectPullDown
@docs singleSelectButton
@docs multiSelectPullDown
@docs multiSelectButton

## `SelectOptions`

@docs SelectOptions

@docs emptySelectOptions
@docs addSelectOption

## `Validation`

@docs Validation

@docs validation
@docs noValidation

# Aliases

@docs ReadValue
@docs ImageSrc
@docs Label
@docs Name
-}

import Css exposing (Stylesheet)
import Dict exposing (Dict)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers exposing (Namespace, withNamespace)
import Html.Events exposing (..)
import Json.Decode exposing (Value)
import Process
import Result
import Task
import Time

import Scenario
import Scenario.UI.Css as Css
import Scenario.UI.Css exposing (CssClasses(..))



-- Exposed aliases


{-| An alias of the `Scenario` type this module use.
-}
type alias DefaultScenario a = Scenario.Scenario ReadArea PrintValue ReadValue a


{-| An alias of `String` for readability.
-}
type alias ReadValue = String


{-| An alias of `String` for readability.
-}
type alias ImageSrc = String


{-| An alias of `String` for readability.
-}
type alias Label = String


{-| An alias of `String` for readability.
-}
type alias Name = String


{-| An alias for `String` representing css namespace.
-}
type alias Namespace = String


-- PrintValue


{-| A type for printed messages.
  This is an opaque type, so construct `PrintValue` values
  with `printImage` or `printString` bellow.
-}
type PrintValue
  = PrintImage ImageSrc
  | PrintString String


{-| A `PrintValue` costructor for image content.
-}
printImage : ImageSrc -> PrintValue
printImage = PrintImage


{-| A `PrintValue` costructor for text content.
-}
printString : String -> PrintValue
printString = PrintString



-- ReadArea


{-| A type representing current state of user input area.
  This is an opaque type, so construct `ReadArea` values
  with constructor functions bellow.
-}
type ReadArea
  = ReadSingleLine InputType Name ReadValue (Validation ReadValue)
  | ReadMultiLine Name ReadValue (Validation ReadValue)
  | ReadSingleSelect SelectMethod Name ReadValue (Validation ReadValue) SelectOptions
  | ReadMultiSelect SelectMethod Name (List ReadValue) (Validation (List ReadValue)) SelectOptions


type InputType
  = InputText
  | InputPassword


type SelectMethod
  = SelectPullDown
  | SelectButton
  -- TODO: SelectSearch


{-| Construct a input field for one-line normal texts.
-}
readSingleText : Name -> ReadValue -> Validation ReadValue -> ReadArea
readSingleText = ReadSingleLine InputText


{-| Construct a input field for password.
  This input field replace user's input with "*"s on the input field,
  but send the input text as it is to the parent component.
-}
readPassword : Name -> ReadValue -> Validation ReadValue -> ReadArea
readPassword = ReadSingleLine InputPassword


{-| Construct a input field for multi-line normal texts.
-}
readMultiLine : Name -> ReadValue -> Validation ReadValue -> ReadArea
readMultiLine = ReadMultiLine


{-| Construct a pull down list for selecting only one value from choices.
  Bellow is an example usage.

    singleSelectPullDown "color" "red" noValidation <|
      emptySelectOptions
        |> addSelectOption "color-red" "Red"
        |> addSelectOption "color-blue" "Blue"
        |> addSelectOption "color-green" "Green"
-}
singleSelectPullDown : Name -> ReadValue -> Validation ReadValue -> SelectOptions -> ReadArea
singleSelectPullDown = ReadSingleSelect SelectPullDown


{-| Construct a set of buttons for selecting only one value from choices.
-}
singleSelectButton : Name -> ReadValue -> Validation ReadValue -> SelectOptions -> ReadArea
singleSelectButton = ReadSingleSelect SelectButton


{-| Same as `singleSelectPullDown` but user can select multiple values.
-}
multiSelectPullDown : Name -> List ReadValue -> Validation (List ReadValue) -> SelectOptions -> ReadArea
multiSelectPullDown = ReadMultiSelect SelectPullDown


{-| Same as `singleSelectButton` but user can select multiple values.
-}
multiSelectButton : Name -> List ReadValue -> Validation (List ReadValue) -> SelectOptions -> ReadArea
multiSelectButton = ReadMultiSelect SelectButton



-- SelectOptions


{-| A opaque type representing user choices.
-}
type SelectOptions =
  SelectOptions (List (ReadValue, Label))


{-| A default value of `SelectOptions`.
-}
emptySelectOptions : SelectOptions
emptySelectOptions = SelectOptions []


{-| Add new choice to a `SelectOptions` value.
-}
addSelectOption : (ReadValue, Label) -> SelectOptions -> SelectOptions
addSelectOption p (SelectOptions opts) =
  SelectOptions <| opts ++ [p]



-- Validation


{-| An opaque type for validating user input.
-}
type Validation a
  = Validation (a -> Result String a)


{-| An constructor for `Validation`.
  An argument is a fnction that get a user input and return

  * `Result.Err` if the input is invalid
  * `Result.Ok` with normalized input value if the input is valid.
-}
validation : (a -> Result String a) -> Validation a
validation = Validation


{-| A validation that always pass user input as it is.
-}
noValidation : Validation a
noValidation = Validation Result.Ok



-- Balloons


{-| An opaque type representing balloons of messages.
  Bellow is an example to construct a `Balloons` value.

    newBalloons =
      emptyBalloons
      |> addSystemBalloon "Hi. This is a system message"
      |> addUserBalloon "Hi. I'm a user."
      |> addSystemBalloon "Good!"
-}
type Balloons =
  Balloons (List Balloon)


type Balloon
  = UserBalloon PrintValue
  | SystemBalloon PrintValue


{-| A default value for `Balloons`.
-}
emptyBalloons : Balloons
emptyBalloons = Balloons []


{-| Add balloon about user input.
-}
addUserBalloon : PrintValue -> Balloons -> Balloons
addUserBalloon v (Balloons balloons) =
  Balloons <| balloons ++ [UserBalloon v]


{-| Add balloon about system message.
-}
addSystemBalloon : PrintValue -> Balloons -> Balloons
addSystemBalloon v (Balloons balloons) =
  Balloons <| balloons ++ [SystemBalloon v]


isUserBalloon : Balloon -> Bool
isUserBalloon balloon =
  case balloon of
    UserBalloon _ ->
      True

    _ ->
      False


balloonMessage : Balloon -> PrintValue
balloonMessage balloon =
  case balloon of
    UserBalloon s ->
      s

    SystemBalloon s ->
      s



-- Config


{-| Configurations.
-}
type Config msg = Config
  { onSubmit : msg
  , onUpdateInput : Result String ReadValue -> msg
  , namespace : String
  }


{-| A constructor for `Config` type.
-}
config :
  { onSubmit : msg -- ^ on submitted
  , onUpdateInput : Result String ReadValue -> msg -- ^ on input updated
  , namespace : String -- ^ name space for css
  } -> Config msg
config o = Config o



-- View


{-| Renderer for `Balloons`.
-}
renderBalloons : Namespace -> Balloons -> Html msg
renderBalloons namespace (Balloons balloons) =
  let
    { id, class, classList } =
      withNamespace namespace
  in
    div
    [ class [ MessageArea ]
    ]
    <| List.map
      (\balloon ->
        div
          [ classList
            [ (Balloon, True)
            , (Css.UserBalloon, isUserBalloon balloon)
            ]
          ]
          <| renderPrintValue (balloonMessage balloon)
      ) balloons


{-| Renderer for `ReadArea`.
TODO current value
-}
renderReadArea : Namespace -> ReadArea -> (Result String ReadValue -> msg) -> Html msg
renderReadArea namespace readArea onInput_ =
  let
    { id, class, classList } =
      withNamespace namespace
  in
    case readArea of
      ReadSingleLine InputText name def (Validation validation) ->
        div [ class [ InputArea ] ]
          [ input
            [ type_ "text"
            , onInput (onInput_ << validation)
            , class [ SingleInput ]
            ]
            []
          ]

      ReadSingleLine InputPassword name_ def (Validation validation) ->
        div [ class [ InputArea ] ]
          [ input
            [ type_ "password"
            , onInput (onInput_ << validation)
            , class [ SingleInput ]
            , defaultValue def
            , name name_
            ]
            []
          ]

      ReadMultiLine name_ def (Validation validation) ->
        div [ class [ InputArea ] ]
          [ textarea
            [ type_ "password"
            , onInput (onInput_ << validation)
            , class [ SingleInput ]
            , name name_
            ]
            -- TODO
            [ text def
            ]
          ]

      _ ->
        -- TODO
        div [ class [ InputArea ] ]
          []


{-| Helper function to render `PrintValue`.
-}
renderPrintValue : PrintValue -> List (Html msg)
renderPrintValue pv =
  case pv of
    (PrintString str) ->
      [ text str
      ]

    (PrintImage src_) ->
      -- TODO: Style
      [ img
        [ src src_ ]
        []
      ]



-- CSS


{-| A CSS component.
Please reffer to the `rtfeldman/elm-css` for detail.
Also, you can see an example in `sample/ui/`.
-}
css : Html.CssHelpers.Namespace String class id msg -> Stylesheet
css = Css.css
