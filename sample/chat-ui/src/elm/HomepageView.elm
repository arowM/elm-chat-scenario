module HomepageView exposing (..)

import Html exposing (..)

import Scenario as Scenario
import Scenario.Styles.ChatUI as ChatUI
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
  { chatUI : ChatUI.Model
  }


init : (Model, Cmd Msg)
init =
  let
    (chatUIModel, chatUICmd) = ChatUI.init sample
  in
    ( { chatUI = chatUIModel
      }
    , Cmd.batch
      [ Cmd.map ChatUI chatUICmd
      ]
    )



-- UPDATE


type Msg
  = ChatUI ChatUI.Msg


update : Msg -> Model -> (Model, Cmd Msg)
update message model =
  case message of
    ChatUI msg ->
      let
        (model_, cmd_) = ChatUI.update msg model.chatUI
      in
        ( { model
          | chatUI = model_
          }
        , Cmd.map ChatUI cmd_
        )



-- VIEW


view : Model -> Html Msg
view model = Html.map ChatUI <|
  ChatUI.view
    ( ChatUI.config
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
