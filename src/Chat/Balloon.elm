module Chat.Balloon
  exposing
    ( Model
    , fromImageBalloon
    , fromTextBalloon
    , setIsUser
    , getIsUser
    , ImageBalloon
    , imageBalloon
    , TextBalloon
    , textBalloon
    , view
    )

{-| A set of functions for creating message balloon for CUI.

# Model

@docs Model

## Constructor

@docs fromImageBalloon
@docs fromTextBalloon

## Setters

@docs setIsUser

## Getters

@docs getIsUser

### `ImageBalloon`

@docs ImageBalloon
@docs imageBalloon

### `TextBalloon`

@docs TextBalloon
@docs textBalloon

# View

@docs view

-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers exposing (withNamespace)
import Chat.Types exposing (ImageSrc, Namespace)


-- Model


{-| An opaque type representing message balloon.
-}
type Model
  = Balloon
    { isUser : Bool
    , body : BalloonBody
    }


type BalloonBody
  = FromImageBalloon ImageBalloon
  | FromTextBalloon TextBalloon


{-| A constructor for `Model` from `TextBalloon`.
  It construct a system message balloon.
  If you want to change it to a user message balloon, use `setIsUser`.
-}
fromTextBalloon : TextBalloon -> Model
fromTextBalloon b =
  Balloon
    { isUser = False
    , body = FromTextBalloon b
    }


{-| A constructor for `Model` from `ImageBalloon`.
  It construct a system message balloon.
  If you want to change it to a user message balloon, use `setIsUser`.
-}
fromImageBalloon : ImageBalloon -> Model
fromImageBalloon b =
  Balloon
    { isUser = False
    , body = FromImageBalloon b
    }


{-| Set a message balloon is of user side or system side.
-}
setIsUser : Bool -> Model -> Model
setIsUser isUser (Balloon balloon) =
  Balloon
    { balloon
      | isUser = isUser
    }


{-| Get a message balloon is of user side or system side.
-}
getIsUser : Model -> Bool
getIsUser (Balloon balloon) =
  balloon.isUser



{-| An opaque type representing a image balloon.
-}
type ImageBalloon
  = ImageBalloon ImageSrc



{-| A constructor for `ImageBalloon`.
   Provide a source image path as an argument.
-}
imageBalloon : ImageSrc -> ImageBalloon
imageBalloon =
  ImageBalloon



{-| An opaque type representing a text message balloon.
-}
type TextBalloon
  = TextBalloon String



{-| A constructor for `TextBalloon`.
   Provide a text message to show as an argument.
-}
textBalloon : String -> TextBalloon
textBalloon =
  TextBalloon



-- View


{-| Renderer for a balloon.
-}
view : Namespace -> Model -> Html msg
view namespace (Balloon balloon) =
  case balloon.body of
    FromTextBalloon body ->
      renderTextBalloon namespace balloon.isUser body

    FromImageBalloon body ->
      renderImageBalloon namespace balloon.isUser body


renderTextBalloon : Namespace -> Bool -> TextBalloon -> Html msg
renderTextBalloon namespace isUser (TextBalloon body) =
  let
    { id, class, classList } =
      withNamespace namespace
  in
    div
      [ classList
        [ (IsUserBalloon, isUser)
        , (BalloonCore, True)
        ]
      ]
      [ text body
      ]


renderImageBalloon : Namespace -> Bool -> ImageBalloon -> Html msg
renderImageBalloon namespace isUser (ImageBalloon imgSrc) =
  let
    { id, class, classList } =
      withNamespace namespace
  in
    div
      [ classList
        [ (IsUserBalloon, isUser)
        , (BalloonCore, True)
        ]
      ]
      [ img
        [ src imgSrc
        ]
        []
      ]


-- Css

type CssClasses
  = IsUserBalloon
  | BalloonCore
