module Scenario.Styles.ChatUI exposing
  ( Model
  , Config
  , Msg
  , update
  , init
  , view
  , config
  )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers exposing (Namespace)
import Html.Events exposing (..)
import Process as Process
import Task as Task
import Time as Time

import Scenario as Scenario
import Scenario.Styles.ChatUI.Css exposing (CssClasses(..))


type alias SimpleScenario a = Scenario.Scenario () String String a


init : SimpleScenario () -> (Model, Cmd Msg)
init scenario =
  ( { scenario = scenario
    , isReadPhase = False
    , history = []
    , input = ""
    }
  , Task.perform
    (always Next)
    (Task.succeed ())
  )


type alias Model =
  { scenario : SimpleScenario ()
  , isReadPhase : Bool
  , history : List BalloonMessage
  , input : String
  }


type alias BalloonMessage =
  { isInput : Bool
  , message : String
  }


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
        , history = model.history ++
          [ { message = str
            , isInput = True
            }
          ]
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
        | history = model.history ++
          [ { message = str
            , isInput = False
            }
          ]
        }

    Next ->
      let
        (model_, cmd_) = Scenario.update scenarioConfig model.scenario
      in
        ( { model | scenario = model_
          }
        , cmd_
        )

    OnEnd ->
      ( model, Cmd.none )



-- View


type Config id = Config
  { title : String
  , buttonLabel : String
  , namespace : Namespace String CssClasses id Msg
  }


config :
  { title : String
  , buttonLabel : String
  , namespace : Namespace String CssClasses id Msg
  } -> Config id
config = Config


view : Config id -> Model -> Html Msg
view (Config config) model =
  let { id, class, classList } =
    config.namespace
  in
    div
      [ class [ Container ]
      ]
      [ div
        [ class [ Header ]
        ]
        [ text config.title
        ]
      , div
        [ class [ MessageArea ]
        ]
        <| List.map
          (\msg ->
            div
              [ classList
                [ (Balloon, True)
                , (IsInput, msg.isInput)
                ]
              ]
              [ text msg.message ]
          ) model.history
      , div
        [ class [ InputArea ] ]
        [ input
          [ type_ "text"
          , value model.input
          , onInput UpdateInput
          , class [ SingleInput ]
          ]
          []
        , button
          [ type_ "button"
          , disabled <| not model.isReadPhase
          , onClick <| Submit model.input
          , class [ SubmitButton ]
          ]
          [ text config.buttonLabel
          ]
        ]
      ]



-- Helper functions


scenarioConfig : Scenario.Config Msg () String String
scenarioConfig = Scenario.config
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
