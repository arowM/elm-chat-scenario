module Chat.InputArea
  exposing
    ( Model
    , fromTextArea
    , fromSelectArea
    , setValues
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
    , noInput
    , view
    , ViewConfig
    )

{-| A set of functions for creating input area of CUI.

# Model

@docs Model

@docs fromTextArea
@docs fromSelectArea
@docs noInput
@docs setValues

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

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Html.Events exposing (..)
import Chat.Types exposing (ReadValue, Namespace, Label)


-- Model


{-| An opaque type representing state of input area.
-}
type Model id
  = FromTextArea id TextArea
  | FromSelectArea id SelectArea
  | NoInput


{-| Construct a `Model` value from `TextArea` value.
-}
fromTextArea : id -> TextArea -> Model id
fromTextArea =
  FromTextArea


{-| Construct a `Model` value from `SelectArea` value.
-}
fromSelectArea : id -> SelectArea -> Model id
fromSelectArea =
  FromSelectArea


{-| Set selected/input values of input area.
  If given `Model` value is `TextArea`, only first value of the given list is applied.
-}
setValues : List String -> Model id -> Model id
setValues vals model =
  case model of
    FromTextArea id textArea ->
      textArea
        |> setTextInput
          ( Maybe.withDefault ""
            <| List.head vals
          )
        |> fromTextArea id

    FromSelectArea id selectArea ->
      selectArea
        |> setSelectedValues vals
        |> fromSelectArea id

    NoInput ->
      NoInput


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
setSelectOptions : SelectOptions -> SelectArea -> SelectArea
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


{-| A `Model` value of with input area.
-}
noInput : Model id
noInput = NoInput



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
      renderTextArea namespace id config area

    FromSelectArea id area ->
      renderSelectArea namespace id config area

    NoInput ->
      renderNoInput namespace


renderTextArea : Namespace -> id -> ViewConfig id msg -> TextArea -> Html msg
renderTextArea namespace ident config (TextArea area) =
  let
    { id, class, classList } =
      withNamespace namespace
  in
    Html.form
      [ onSubmit <| config.onSubmit ident [ area.input ] ]
      [ case area.textType of
        SingleLineText ->
          input
            [ type_ "text"
            , value area.input
            , onInput <| config.onInput ident << \s -> [ s ]
            ]
            []

        SingleLinePassword ->
          input
            [ type_ "password"
            , value area.input
            , onInput <| config.onInput ident << \s -> [ s ]
            ]
            []

        MultiLineText ->
          textarea
            [ value area.input
            , onInput <| config.onInput ident << \s -> [ s ]
            ]
            []
      , button
        [ type_ "submit" ]
        [ text "Submit"
        ]
      ]


renderSelectArea : Namespace -> id -> ViewConfig id msg -> SelectArea -> Html msg
renderSelectArea namespace id config (SelectArea area) =
  let
    { id, class, classList } =
      withNamespace namespace
  in
    -- TODO
    div
      []
      []


renderNoInput : Namespace -> Html msg
renderNoInput namespace =
  let
    { id, class, classList } =
      withNamespace namespace
  in
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
