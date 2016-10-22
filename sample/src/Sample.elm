import Scenario exposing (Scenario)


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
