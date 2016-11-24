import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Process as Process
import Task as Task
import Time as Time
import Debug as Debug

import Scenario as Scenario



-- APP


main : Program Never Model Msg
main =
  program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }



-- MODEL


type alias Model =
  { scenario : SimpleScenario ()
  , isReadPhase : Bool
  , history : List String
  , input : String
  }


init : (Model, Cmd Msg)
init =
  ( { scenario = sample
    , isReadPhase = False
    , history = []
    , input = ""
    }
  , Task.perform
    (always Next)
    (Task.succeed ())
  )



-- UPDATE


type Msg
  = Submit String
  | UpdateInput String
  | AskRead ()
  | ShowPrint String
  | Next
  | OnEnd


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    Submit str ->
      update
        Next
        { model
        | scenario = Scenario.pushAnswer str model.scenario
        , isReadPhase = False
        , input = ""
        }

    UpdateInput str ->
      ( { model
        | input = str
        }
      , Cmd.none
      )

    AskRead () ->
      ( { model
        | isReadPhase = True
        }
      , Cmd.none
      )

    ShowPrint str ->
      update
        Next
        { model
        | history = model.history ++ [str]
        }

    Next ->
      let
        (model_, cmd_) = Scenario.update config model.scenario
      in
        ( { model | scenario = model_
          }
        , cmd_
        )

    OnEnd ->
      ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
  div [] [
    div []
      <| List.map
        (\str ->
          div [] [ text str ]
        ) model.history
  , div []
    [ input
      [ type_ "text"
      , value model.input
      , onInput UpdateInput
      ]
      []
    ]
  , div []
    [ button
      [ type_ "button"
      , disabled <| not model.isReadPhase
      , onClick <| Submit model.input
      ]
      [ text "submit"
      ]
    ]
  ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none



-- Helper functions


config : Scenario.Config Msg () String String
config = Scenario.config
  (\t -> Task.perform
    ShowPrint
    (Process.sleep
      (1 * Time.second)
      |> Task.andThen (always <| Task.succeed t)
    )
  )
  (Task.perform
    (always OnEnd)
    (Task.succeed ())
  )
  (\c -> Task.perform
    AskRead
    (Task.succeed c)
  )


type alias SimpleScenario a = Scenario.Scenario () String String a


sample : SimpleScenario ()
sample =
  Scenario.print "This is a test scenario."
  |> Scenario.andAlways (Scenario.print "What's your name?")
  |> Scenario.andAlways (Scenario.read ())
  |> Scenario.andThen (\name -> Scenario.print <| "Hi " ++ name ++ "!")
