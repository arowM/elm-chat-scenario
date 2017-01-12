module Chat.Balloon.Css
  exposing
    ( CssClasses(..)
    , css
    )

{-| A css related functions for chat message balloon.

# Core

@docs Css
@css

-}

import Css exposing (..)



-- Css

type CssClasses
  = IsUserBalloon
  | BalloonCore


css : List Snippet
css =
  [ (.) BalloonCore
    [ border3 (px 2.4) solid mainColor
    , borderRadius (px 4)
    , margin3 zero zero (em 0.5)
    , position relative
    , lineHeight (em 2)
    , color textColor
    , textAlign left
    , backgroundColor lightMainColor
    , fontSize (em 1.2)
    , margin2 (em 0.4) (em 0.4)
    , padding2 (em 0.2) (em 0.4)
    ]
  , (.) IsUserBalloon
    [ backgroundColor lightPrimaryColor
    , borderColor primaryColor
    ]
  ]

lightMainColor : Color
lightMainColor = hex "aee7ff"
mainColor : Color
mainColor = hex "5ea7e1"
textColor : Color
textColor = hex "1b5a74"
primaryColor : Color
primaryColor = hex "94cf85"
darkPrimaryColor : Color
darkPrimaryColor = hex "7caa70"
lightPrimaryColor : Color
lightPrimaryColor = hex "aade9d"
secondaryColor : Color
secondaryColor = hex "dec575"
darkColor : Color
darkColor = hex "3c85bf"
white : Color
white = hex "fff"
black : Color
black = hex "000"

