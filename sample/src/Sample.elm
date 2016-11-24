import Scenario exposing (..)


type alias SimpleScenario a = Scenario () String String a


sample : SimpleScenario ()
sample =
  print "Test"
  |> andAlways (print "What's your name?")
  |> andAlways (read ())
  |> andThen (\name -> print <| "Hi " ++ name ++ "!")
