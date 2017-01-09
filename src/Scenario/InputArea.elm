module Scenario.InputArea
  exposing
    ( Model
    , fromTextArea
    , fromSelectArea
    , TextArea
    , defaultTextArea
    , setTextInput
    , setTextType
    , TextType
    , singleLineText
    , singleLinePassword
    , multiLineText
    , SelectArea
    , defaultSelectArea
    , setSelectedValues
    , setSelectMethod
    , setSelectOptions
    , SelectMethod
    , selectPullDown
    , selectButton
    , SelectOptions
    , emptySelectOptions
    , addSelectOption
    , view
    , ViewConfig
    )

{-| A set of functions for creating input area of CUI.

# Model

@docs Model

@docs fromTextArea
@docs fromSelectArea

## `TextaArea`

@docs TextArea

### Constructors

@docs defaultTextArea

### Setters

@docs setTextInput
@docs setTextType

#### `TextType`

@docs TextType

@docs singleLineText
@docs singleLinePassword
@docs multiLineText

## `SelectArea`

@docs SelectArea

### Constructors

@docs defaultSelectArea

### Setters

@docs setSelectedValues
@docs setSelectMethod
@docs setSelectOptions

#### `SelectMethod`

@docs SelectMethod
@docs selectPullDown
@docs selectButton

#### `SelectOptions`

@docs SelectOptions
@docs emptySelectOptions
@docs addSelectOption

# View

@docs view

# Exposed aliases

@docs ViewConfig

-}

import Scenario


-- Model


{-| An opaque type representing state of input area.
-}
type Model id
  = FromTextArea id TextArea
  | FromSelectArea id SelectArea


{-| Construct a `Model` value from `TextArea` value.
-}
fromTextArea : id -> TextArea -> Model id
fromTextArea =
  FromTextArea


{-| Construct a `Model` value from `SelectArea` value.
-}
fromSelectArea : id -> SelectArea -> Model id
fromSelectArea =
  FromSelecArea


{-| An opaque type representing a text input area.
-}
type TextArea
  = TextArea
    { input : ReadValue
    , textType : TextType
    }


{-| A constructor for `TextArea` to construct an empty single line text input area.
-}
defaultTextArea : TextArea
defaultTextArea =
  TextArea
    { input = ""
    , textType = SingleLineText
    }


{-| Set input text content.
-}
setTextInput : String -> TextArea -> TextArea
setTextInput str (TextArea area) =
  TextArea
    { area
      | input = str
    }


{-| Set appearance of an text input area.
-}
setTextType : TextType -> TextArea -> TextArea
setTextType t (TextArea area) =
  TextArea
    { area
      | textType = t
    }


{-| An opaque type representing appearance of text input area.
-}
type TextType
  = SingleLineText
  | SingleLinePassword
  | MultiLineText


{-| A `TextType` value representing a single line text input.
-}
singleLineText : TextType
singleLineText =
  SingleLineText


{-| A `TextType` value representing a single line password input.
-}
singleLinePassword : TextType
singleLinePassword =
  SingleLinePassword


{-| A `TextType` value representing a multi line text input.
-}
multiLineText : TextType
multiLineText =
  MultiLineText


{-| An opaque type representing a select area.
-}
type SelectArea
  = SelectArea
    { selected : List String
    , method : SelectMethod
    , options : SelectOptions
    }


{-| A constructor for `SelectArea` to construct an check buttons.
  Note that this `defaultSelectArea` does not have any items, so use `setSelectOptions` to add acutual check buttons.
-}
defaultSelectArea : SelectArea
defaultSelectArea =
  SelectArea
    { selected = []
    , method = SelectButton
    , options = emptySelectOptions
    }


{-| Set selected values.
-}
setSelectedValues : List String -> SelectArea -> SelectArea
setSelectedValues vals (SelectArea area) =
  SelectArea
    { area
      | selected = vals
    }


{-| Set select method.
-}
setSelectMethod : SelectMethod -> SelectArea -> SelectArea
setSelectMethod method (SelectArea area) =
  SelectArea
    { area
      | method = method
    }


{-| Set select options.
-}
setSelectOptions opts (SelectArea area) =
  SelectArea
    { area
      | options = opts
    }


{-| An opaque type representing a method to select user choices.
-}
type SelectMethod
  = SelectPullDown
  | SelectButton



-- TODO: SelectSearch


{-| A select method of pull down list.
-}
selectPullDown : SelectMethod
selectPullDown =
  SelectPullDown


{-| A select method of check buttons.
-}
selectButton : SelectMethod
selectButton =
  SelectButton


{-| An opaque type representing user choices.
-}
type SelectOptions
  = SelectOptions (List ( ReadValue, Label ))


{-| A default value of `SelectOptions`.
-}
emptySelectOptions : SelectOptions
emptySelectOptions =
  SelectOptions []


{-| Add new choice to a `SelectOptions` value.
-}
addSelectOption : ( ReadValue, Label ) -> SelectOptions -> SelectOptions
addSelectOption p (SelectOptions opts) =
  SelectOptions <| opts ++ [ p ]



-- View


{-| A renderer for input area.

  The first argument is a name space for
  [elm-css](https://github.com/rtfeldman/elm-css).
  It is supposed to be a unique value.
-}
view : Namespace -> ViewConfig id msg -> Model id -> Html msg
view namespace config model =
  case model of
    FromTextArea id area ->
      renderTextArea config id area

    FromSelectArea config id area ->
      renderSelectArea id area


renderTextArea : id -> ViewConfig id msg -> TextArea -> Html msg
renderTextArea id config (TextArea area) =
  let
    { id, class, classList } =
      withNamespace namespace
  in
    div
      []
      [ case area.textType of
        SingleLineText ->
          input
            [ type_ "text"
            , value area.input
            ]
            []

        SingleLinePassword ->
          input
            [ type_ "password"
            , value area.input
            ]
            []

        MultiLineText ->
          textarea
            [ value area.input
            ]
            []
      ]


renderSelectArea : id -> ViewConfig id msg -> SelectArea -> Html msg
renderSelectArea id config (SelectArea area) =
  let
    { id, class, classList } =
      withNamespace namespace
  in
    -- TODO
    div
      []
      []



-- Exposed aliases


{-| An alias of configurations for `view`.

  The `onInput` is a function fired when user update inputs.
  The `onSubmit` is a function fired when user submit their inputs.
-}
type alias ViewConfig id msg =
  { onInput : id -> List String -> msg
  , onSubmit : id -> List String -> msg
  }
