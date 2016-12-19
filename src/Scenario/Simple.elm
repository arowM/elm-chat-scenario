module Scenario.Simple exposing
  ( Model
  , Config
  , Msg
  , update
  , init
  , view
  , config
  )

{-| A Conversational User Interface component.

# Common Types

@docs Model
@docs Config
@docs Msg
@docs update
@docs init
@docs view
@docs config

-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers exposing (Namespace)
import Html.Events exposing (..)
import Process as Process
import Task as Task
import Time as Time

import Scenario as Scenario
import Scenario.Simple.Css exposing (CssClasses(..))


type alias SimpleScenario a = Scenario.Scenario () String String a


init : SimpleScenario () -> (Model, Cmd Msg)
init scenario =
  ( Model
    { scenario = scenario
    , isReadPhase = False
    , history = []
    , input = ""
    }
  , Task.perform
    (always Next)
    (Task.succeed ())
  )


type Model = Model
  { scenario : SimpleScenario ()
  , isReadPhase : Bool
  , history : List BalloonMessage
  , input : String
  }


type alias BalloonMessage =
  { isInput : Bool
  , message : String
  , beforeFadeIn : Bool
  }


type Msg
  = Submit String
  | UpdateInput String
  | AskRead ()
  | ShowPrint String
  | Next
  | FadeIn (Cmd Msg)
  | OnEnd


update : Msg -> Model -> (Model, Cmd Msg)
update message (Model model) =
  case message of
    Submit str ->
      update
        Next
        <| Model
          { model
          | scenario = Scenario.pushAnswer str model.scenario
          , isReadPhase = False
          , input = ""
          , history = model.history ++
            [ { message = str
              , isInput = True
              , beforeFadeIn = True
              }
            ]
          }

    UpdateInput str ->
      ( Model
        { model
        | input = str
        }
      , Cmd.none
      )

    AskRead () ->
      ( Model
        { model
        | isReadPhase = True
        }
      , Cmd.none
      )

    ShowPrint str ->
      update
        Next
        <| Model
          { model
          | history = model.history ++
            [ { message = str
              , isInput = False
              , beforeFadeIn = True
              }
            ]
          }

    Next ->
      let
        (model_, cmd_) = Scenario.update scenarioConfig model.scenario
      in
        ( Model
          { model | scenario = model_
          }
        , (Task.perform
            (always (FadeIn cmd_))
            (Process.sleep
              (1 * Time.second)
              |> Task.andThen (always <| Task.succeed ())
            )
          )
        )

    FadeIn cmd_ ->
      ( Model
        { model
        | history =
          List.map
          (\x ->
            { x
            | beforeFadeIn = False
            }
          )
          model.history
        }
      , cmd_
      )

    OnEnd ->
      ( Model model, Cmd.none )



-- View

{-| Configuration for view.
  * `title`: Main title of this chat
  * `buttonLabel`: Label name of submit button
  * `namespace`: A name space for css.
-}
type Config id = Config
  { title : String
  , buttonLabel : String
  , namespace : Namespace String CssClasses id Msg
  }


{-| A constructor for `Config`.
  * `title`: Main title of this chat
  * `buttonLabel`: Label name of submit button
  * `namespace`: A name space for css.
-}
config :
  { title : String
  , buttonLabel : String
  , namespace : Namespace String CssClasses id Msg
  } -> Config id
config = Config


{-| Default view.
-}
view : Config id -> Model -> Html Msg
view (Config config) (Model model) =
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
                , (BeforeFadeIn, msg.beforeFadeIn)
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
    (Task.succeed t)
  )
  (Task.perform
    (always OnEnd)
    (Task.succeed ())
  )
  (\c -> Task.perform
    AskRead
    (Task.succeed c)
  )
