module HomepageView exposing (..)

import Html exposing (..)

import Scenario as Scenario
import Scenario.Simple as Simple
import Stylesheets exposing (mynamespace)



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
  { chatUI : Simple.Model
  }


init : (Model, Cmd Msg)
init =
  let
    (chatUIModel, chatUICmd) = Simple.init sample
  in
    ( { chatUI = chatUIModel
      }
    , Cmd.batch
      [ Cmd.map Simple chatUICmd
      ]
    )



-- UPDATE


type Msg
  = Simple Simple.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    Simple msg ->
      let
        (model_, cmd_) = Simple.update msg model.chatUI
      in
        ( { model
          | chatUI = model_
          }
        , Cmd.map Simple cmd_
        )



-- VIEW


view : Model -> Html Msg
view model = Html.map Simple <|
  Simple.view
    ( Simple.config
      { title = "elm-chat-scenario-sample"
      , buttonLabel = "submit"
      , namespace = mynamespace
      }
    )
    model.chatUI



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ = Sub.none



type alias SimpleScenario a = Scenario.Scenario () String String a


sample : SimpleScenario ()
sample =
  Scenario.print "This is a test scenario."
  |> Scenario.andAlways (Scenario.print "What's your name?")
  |> Scenario.andAlways (Scenario.read ())
  |> Scenario.andThen (\name -> Scenario.print <| "Hi " ++ name ++ "!")
