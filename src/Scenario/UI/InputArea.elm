module Scenario.UI.InputArea
  exposing
    ( Model
    , defaultModel
    , setSelections
    , setInput
    )

{-| A set of functions for creating input area of CUI.

# Model

@docs Model

## Constructors

@docs defaultModel

## Setters

@docs setSelections
@docs setInput

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

# View

@docs renderReadArea

-}

import Scenario.UI


-- Model


{-| An opaque type representing state of conversations.
-}
type Model
  = Model
    { selections : List ReadValue
    , input : ReadValue
    }


{-| A constructor for `Model`. It constructs default `Model` value.
-}
defaultModel : Model
defaultModel =
  Model
    { selections = []
    , input = ""
    }


{-| Set selected values of the input area.
-}
setSelections : List ReadValue -> Model -> Model
setSelections vals (Model model) =
  Model
    { model
      | selections = vals
    }


{-| Set input value of the input area.
-}
setInput : ReadValue -> Model -> Model
setInput val (Model model) =
  Model
    { model
      | input = val
    }



-- Config


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



-- View


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
      ReadSingleLine InputText name_ val (Validation validation) ->
        div [ class [ InputArea ] ]
          [ input
            [ type_ "text"
            , onInput (onInput_ << validation)
            , class [ SingleInput ]
            , value val
            , name name_
            ]
            []
          ]

      ReadSingleLine InputPassword name_ val (Validation validation) ->
        div [ class [ InputArea ] ]
          [ input
            [ type_ "password"
            , onInput (onInput_ << validation)
            , class [ SingleInput ]
            , value val
            , name name_
            ]
            []
          ]

      ReadMultiLine name_ val (Validation validation) ->
        div [ class [ InputArea ] ]
          [ textarea
            [ type_ "password"
            , onInput (onInput_ << validation)
            , class [ SingleInput ]
            , name name_
            ]
            [ text val
            ]
          ]

      _ ->
        -- TODO
        div [ class [ InputArea ] ]
          []
