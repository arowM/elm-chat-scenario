module Scenario exposing
  ( Scenario
  , TalkConfig
  , TalkParagraph
  , ChoiceConfig
  , InputConfig
  , succeed
  , andThen
  , andAlways
  , map
  , talk
  , talkConfig
  , choice
  , singleInput
  , multiInput
  , customInput
  , tagInput
  , tagTextArea
  , tagSelect
  , tagCustom
  )

{-| Type safe scenario model for chat like UI.

# Common Types

@docs Scenario

# Dominant functions to construct scenario

@docs talk
@docs choice
@docs andThen
@docs andAlways

# Types and functions to construct talk script

@docs TalkConfig
@docs TalkParagraph
@docs talkConfig
@docs tagInput
@docs tagTextArea
@docs tagSelect
@docs tagCustom

# Functions to construct input area

@docs ChoiceConfig
@docs InputConfig
@docs singleInput
@docs multiInput
@docs customInput

# Rarely used but important functions

@docs succeed
@docs map
-}


import Dict exposing (Dict)
import Html exposing (Attribute, Html)
import Json.Encode exposing (Value)


{-| Main type of this module to represent scenario.
-}
type Scenario msg a
  = Talk TalkConfig (Scenario msg a)
  | Choice (ChoiceConfig msg) (Value -> Scenario msg a)
  | Pure a


{-| Construct scenario with any state.
-}
succeed : a -> Scenario msg a
succeed = Pure


{-| Combine two scenarios to make one scenario.
-}
andThen : Scenario msg a -> (a -> Scenario msg b) -> Scenario msg b
andThen s f =
  case s of
    Talk c next ->
      Talk c (next `andThen` f)

    Choice c g ->
      Choice c (\v -> g v `andThen` f)

    Pure a ->
      f a


{-| Similar to `andThen`, but ignores previous state.
-}
andAlways : Scenario msg a -> Scenario msg b -> Scenario msg b
andAlways s1 s2 = s1 `andThen` always s2


{-| Convert scenario state by given function.
-}
map : (a -> b) -> Scenario msg a -> Scenario msg b
map f m = m `andThen` (succeed << f)


{-| Construct scenario contains only one talk script.
-}
talk : TalkConfig -> Scenario msg ()
talk conf = Talk conf <| succeed ()


{-| Construct scenario contains only one choice event.
-}
choice : ChoiceConfig msg -> Scenario msg Value
choice conf = Choice conf <| succeed



-- FUNCTIONS TO CONSTRUCT CONFIG


{-| A type representing a talk script.
-}
type TalkConfig = TalkConfig
  { speaker : Speaker
  , feeling : Maybe Feeling
  , body : List TalkParagraph
  }


{-| A type representing a paragraph of talk script.
-}
type TalkParagraph =
  { ptag : ParagraphTag
  , text : String
  }


{-| Represents speaker of a talk script
-}
type Speaker
  = AI
  | User


{-| Feeling of the speaker of a talk script.
-}
type Feeling
  = FeelNormal
  | FeelBad
  | FeelGood


{-| Which role a paragraph have?
    Its role is like a HTML tag.
-}
type ParagraphTag
  = PlainParagraph
  | AnnotationParagraph
  | ImportantParagraph
  | TitleParagraph
  | SubParagraph
  | ImageParagraph
  | CustomParagraph String


{-| Representing a choice event.
-}
type ChoiceConfig msg
  = SingleInput
    { inputArea : InputArea msg
    , submitButton : SubmitButton msg
    }
  | MultiInput
    { inputAreas : List (InputArea msg)
    , submitButton : SubmitButton msg
    }
  | CustomInput String (Dict String Value)


{-| Representing a input area of a choice event.
-}
type alias InputArea msg =
  { attr : List (Attribute msg)
  , preContent : Html msg
  , input : InputConfig msg
  , postContent : Html msg
  }


{-| Representing a submit button of a choice event.
-}
type alias SubmitButton msg =
  { attr : List (Attribute msg)
  , label : String
  }


{-| A method to construct the `InputConfig' having only one-line input area.
    (e.g., for one-line phone number input, email input, simple comment...)
-}
singleInput : InputArea msg -> SubmitButton msg -> InputConfig msg
singleInput input submit = SingleInput
  { inputArea = input
  , submitButton = submit
  }


{-| A method to construct the `InputConfig' having multi input area.
    (e.g., for name input with family name box, given name box, and middle name box.)
-}
multiInput : List (InputArea msg) -> SubmitButton msg -> InputConfig msg
multiInput inputs submit = MultiInput
  { inputAreas = inputs
  , submitButton = submit
  }


{-| A method to construct the `InputConfig' of custom type.
    The first argument is identifire of this custom type,
    and the second one is dictionary of settings for this custom type used on rendering.
-}
customInput : String -> (Dict String Value) -> InputConfig msg
customInput = CustomInput


{-| A method to construct the `TalkConfig'.
-}
talkConfig : Speaker -> Maybe Feeling -> List TalkParagraph -> TalkConfig
talkConfig s mf ps =
  TalkConfig
    { speaker = s
    , feeling = mf
    , body = ps
    }


{-| A method to construct the `TalkParagraph'.
-}
talkParagraph : ParagraphTag -> String -> TalkParagraph
talkParagraph ptag text = TalkParagraph
  { ptag : ptag
  , text : text
  }


-- InputConfig


type InputConfig msg
  = TagInput (List (Attribute msg)) (List (Html msg))
  | TagTextArea (List (Attribute msg)) (List (Html msg))
  | TagSelect (List (Attribute msg)) (List (Html msg))
  | TagCustom String (List (Attribute msg)) (List (Html msg))


-- HELPER FUNCTIONS


tagInput : List (Attribute msg) -> List (Html msg) -> InputConfig msg
tagInput = TagInput


tagTextArea : List (Attribute msg) -> List (Html msg) -> InputConfig msg
tagTextArea = TagTextArea


tagSelect : List (Attribute msg) -> List (Html msg) -> InputConfig msg
tagSelect = TagSelect


{-| Make input area with custom tag.
    The first argument is the custom tag name.
-}
tagCustom : String -> List (Attribute msg) -> List (Html msg) -> InputConfig msg
tagCustom = TagCustom


sampleScenario :: Scenario msg ()
sampleScenario =
  talk <| talkConfig AI Nothing
    [ { PlainParagraph
      , "Test"
      }
    , { ImportantParagraph
      , "Is this important question?"
      }
    ] `andAlways`
  choice <| SingleInput

choice : ChoiceConfig msg -> Scenario msg Value
choice conf = Choice conf <| succeed


type ChoiceConfig msg
  = SingleInput
    { inputArea : InputArea msg
    , submitButton : SubmitButton msg
    }
  | MultiInput
    { inputAreas : List (InputArea msg)
    , submitButton : SubmitButton msg
    }
  | CustomInput String (Dict String Value)
