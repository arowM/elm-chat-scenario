module Components.Scenario.InputAreaConfig exposing
  ( Scenario
  , TalkConfig
  , ChoiceConfig
  , succeed
  , andThen
  , talk
  , choice
  )
{-| Helper functions for
    `Components.Scenario.InputAreaConfig` data type
-}


import Html exposing (Html)
import Attribute exposing (Attribute)


type InputAreaConfig
  = TagInput (List Attribute) (List (Html msg))
  | TagTextArea (List Attribute) (List (Html msg))
  | TagSelect (List Attribute) (List (Html msg))
  | TagCustom String (List Attribute) (List (Html msg))


-- HELPER FUNCTIONS


tagInput : List Attribute -> List Html -> InputAreaConfig
tagInput = TagInput


tagTextArea : List Attribute -> List Html -> InputAreaConfig
tagTextArea = TagTextArea


tagSelect : List Attribute -> List Html -> InputAreaConfig
tagSelect = TagSelect


{-| Make input area with custom tag.
    The first argument is the custom tag name.
-}
tagCustom : String -> List Attribute -> List Html -> InputAreaConfig
tagCustom = TagSelect
