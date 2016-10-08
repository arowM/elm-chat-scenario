module Scenario exposing
  ( Scenario
  , TalkConfig
  , ChoiceConfig
  , InputConfig
  , succeed
  , andThen
  , map
  , talk
  , choice
  , talkConfig
  , tagInput
  , tagTextArea
  , tagSelect
  , tagCustom
  )
{-| Type safe scenario model for chat like UI.

# Types

@docs Scenario
@docs TalkConfig
@docs ChoiceConfig
@docs InputConfig

# Common functions

@docs succeed
@docs andThen
@docs map

# Functions to construct scenario

@docs talk
@docs choice

# Functions to construct tags

@docs talkConfig
@docs tagInput
@docs tagTextArea
@docs tagSelect
@docs tagCustom

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


map : (a -> b) -> Scenario msg a -> Scenario msg b
map f m = m `andThen` (succeed << f)


talk : TalkConfig -> Scenario msg ()
talk conf = Talk conf <| succeed ()


choice : ChoiceConfig msg -> Scenario msg Value
choice conf = Choice conf <| succeed



-- CONFIG MAKERS


type TalkConfig = TalkConfig
  { speaker : Speaker
  , feeling : Maybe Feeling
  , body : List TalkParagraph
  }


type alias TalkParagraph =
  { ptag : ParagraphTag
  , text : String
  }


{-| Owner of a talk balloon
-}
type Speaker
  = AI
  | User


{-| Feeling of the owner
-}
type Feeling
  = FeelNormal
  | FeelBad
  | FeelGood


{-| Which meanings of the paragraph?
-}
type ParagraphTag
  = PlainParagraph
  | AnnotationParagraph
  | ImportantParagraph
  | TitleParagraph
  | SubParagraph
  | ImageParagraph


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


type alias InputArea msg =
  { attr : List (Attribute msg)
  , preContent : Html msg
  , input : InputConfig msg
  , postContent : Html msg
  }


type alias SubmitButton msg =
  { attr : List (Attribute msg)
  , label : String
  }


talkConfig : Speaker -> Maybe Feeling -> List TalkParagraph -> TalkConfig
talkConfig s mf ps =
  TalkConfig
    { speaker = s
    , feeling = mf
    , body = ps
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
