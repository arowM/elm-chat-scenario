module Scenario.UI exposing
  ( DefaultScenario
  , ReadValue
  , ImageSrc
  , Label
  , Name
  , DefaultValue
  , PrintValue
  , printImage
  , printString
  , ReadConfig
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
  , State
  , defaultState
  , view
  , css
  )

{-| A set of functions for creating usual Conversational User Interface.

# Scenario

@docs DefaultScenario

# View

@docs view

# CSS

@docs css

# `State`

@docs State

@docs defaultState

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

# `ReadConfig`

@docs ReadConfig

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
@docs DefaultValue
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
type alias DefaultScenario a = Scenario.Scenario ReadConfig PrintValue ReadValue a


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


{-| An alias for `ReadValue` representing a value the input area shows at first.
-}
type alias DefaultValue = ReadValue



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



-- ReadConfig


{-| A type for specifying how to read user inputs.
  This is an opaque type, so construct `ReadConfig` values
  with constructor functions bellow.
-}
type ReadConfig
  = ReadSingleLine InputType Name DefaultValue (Validation ReadValue)
  | ReadMultiLine Name DefaultValue (Validation ReadValue)
  | ReadSingleSelect SelectMethod Name DefaultValue (Validation ReadValue) SelectOptions
  | ReadMultiSelect SelectMethod Name (List DefaultValue) (Validation (List ReadValue)) SelectOptions


type InputType
  = InputText
  | InputPassword


type SelectMethod
  = SelectPullDown
  | SelectButton
  -- TODO: SelectSearch


{-| Construct a input field for one-line normal texts.
-}
readSingleText : Name -> DefaultValue -> Validation ReadValue -> ReadConfig
readSingleText = ReadSingleLine InputText


{-| Construct a input field for password.
  This input field replace user's input with "*"s on the input field,
  but send the input text as it is to the parent component.
-}
readPassword : Name -> DefaultValue -> Validation ReadValue -> ReadConfig
readPassword = ReadSingleLine InputPassword


{-| Construct a input field for multi-line normal texts.
-}
readMultiLine : Name -> DefaultValue -> Validation ReadValue -> ReadConfig
readMultiLine = ReadMultiLine


{-| Construct a pull down list for selecting only one value from choices.
  Bellow is an example usage.

    singleSelectPullDown "color" "red" noValidation <|
      emptySelectOptions
        |> addSelectOption "color-red" "Red"
        |> addSelectOption "color-blue" "Blue"
        |> addSelectOption "color-green" "Green"
-}
singleSelectPullDown : Name -> DefaultValue -> Validation ReadValue -> SelectOptions -> ReadConfig
singleSelectPullDown = ReadSingleSelect SelectPullDown


{-| Construct a set of buttons for selecting only one value from choices.
-}
singleSelectButton : Name -> DefaultValue -> Validation ReadValue -> SelectOptions -> ReadConfig
singleSelectButton = ReadSingleSelect SelectButton


{-| Same as `singleSelectPullDown` but user can select multiple values.
-}
multiSelectPullDown : Name -> List DefaultValue -> Validation (List ReadValue) -> SelectOptions -> ReadConfig
multiSelectPullDown = ReadMultiSelect SelectPullDown


{-| Same as `singleSelectButton` but user can select multiple values.
-}
multiSelectButton : Name -> List DefaultValue -> Validation (List ReadValue) -> SelectOptions -> ReadConfig
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


{-| An opaque type representing ballons of messages.
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



-- State


{-| An opaque type representing component state.
-}
type State = State
  { title : String
  , submitButton :
    { label : Label
    , disabled : Bool
    }
  , history : Balloons
  , input : ReadValue
  }


{-| A default `State` value.
-}
defaultState : State
defaultState = State
  { title = ""
  , submitButton =
    { label = "Submit"
    , disabled = True
    }
  , history = Balloons []
  , input = ""
  }



-- View


{-| A default view.
-}
view : Config msg -> State -> Html msg
view (Config config) (State state) =
  let
    { id, class, classList } =
      withNamespace config.namespace
    (Balloons history) = state.history
  in
    div
      [ class [ Container ]
      ]
      [ div
        [ class [ Header ]
        ]
        [ text state.title
        ]
      , div
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
          ) history
      , div
        -- TODO
        [ class [ InputArea ] ]
        [ input
          [ type_ "text"
          , onInput (config.onUpdateInput << Result.Ok)
          , class [ SingleInput ]
          ]
          []
        , button
          [ type_ "button"
          , disabled <| not state.submitButton.disabled
          , onClick config.onSubmit
          , class [ SubmitButton ]
          ]
          [ text state.submitButton.label
          ]
        ]
      ]


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
