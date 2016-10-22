import Scenario exposing (..)


sampleScenario : Scenario msg ()
sampleScenario =
  talk <| talkConfig AI Nothing
    [ { PlainParagraph
      , "Test"
      }
    , { ImportantParagraph
      , "Is this important question?"
      }
    ]
