module HomepageCss exposing (css)

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)
import SharedStyles exposing (..)

css : Stylesheet
css =
    (stylesheet << namespace homepageNamespace.name)
        [ everything
            [ boxSizing borderBox
            , fontFamily cursive
            , padding zero
            , margin zero
            , lineHeight (num 1.15)
            , height auto
            , width auto
            , property "border" "none"
            , textDecoration none
            , fontWeight normal
            , fontStyle normal
            , fontSize (em 1)
            , boxShadow none
            , color textColor
            ]
        , (.) Container
            [ displayFlex
            , flexDirection column
            , height (vh 100)
            , minHeight (pct 100)
            , maxWidth (em 60)
            , margin2 zero auto
            ]
        , (.) Header
            [ width (pct 100)
            , minHeight (em 2)
            , backgroundColor mainColor
            , boxShadow5 zero (px 4) (px 4) (px -4) darkColor
            , fontSize (em 1.4)
            , color white
            , textAlign center
            , padding3 (em 0.5) zero (em 0.5)
            ]
        , (.) MessageArea
            [ flex (int 1)
            , overflowY scroll
            , children
              [ (.) Balloon
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
              , (.) IsInput
                [ backgroundColor lightPrimaryColor
                , borderColor primaryColor
                ]
              ]
            ]
        , (.) InputArea
            [ width (pct 100)
            , minHeight (em 2)
            , backgroundColor mainColor
            , boxShadow5 zero (px -4) (px -4) (px 4) darkColor
            , fontSize (em 1.4)
            , color white
            , textAlign right
            , padding3 (em 0.5) (em 0.5) (em 0.5)
            , children
              [ everything
                [ fontSize (em 1.1)
                , height (em 1.6)
                ]
              , (.) SingleInput
                [ borderRadius (px 6)
                , width (pct 100)
                , maxWidth (em 20)
                , padding2 zero (em 0.4)
                ]
              , (.) SubmitButton
                [ borderRadius (px 6)
                , minWidth (em 6)
                , marginLeft (em 1.4)
                , backgroundColor primaryColor
                , cursor pointer
                , hover
                  [ backgroundColor lightPrimaryColor
                  ]
                , disabled
                  [ backgroundColor darkPrimaryColor
                  , color white
                  , cursor default
                  ]
                ]
              ]
            ]
        ]

lightMainColor = hex "aee7ff"
mainColor = hex "5ea7e1"
textColor = hex "1b5a74"
primaryColor = hex "94cf85"
darkPrimaryColor = hex "7caa70"
lightPrimaryColor = hex "aade9d"
secondaryColor = hex "dec575"
darkColor = hex "3c85bf"
white = hex "fff"
black = hex "000"
