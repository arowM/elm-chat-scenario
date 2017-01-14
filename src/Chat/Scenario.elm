module Chat.Scenario
    exposing
        ( Model
        , print
        , read
        , andThen
        , andAlways
        , step
        , StepConfig
        , stepConfig
        , pushAnswer
        , succeed
        , map
        )

{-| A type safe DSL for a chat scenario.

# Common Types

@docs Model

# Convenient functions to construct scenario

@docs print
@docs read
@docs andThen
@docs andAlways

# Functions to run scenario model

@docs step
@docs pushAnswer

# Configurations for running scenario

@docs StepConfig
@docs stepConfig

# Rarely used but important functions

@docs succeed
@docs map

-}


-- Model


{-| Main type of this module to represent scenario.
-}
type Model c t v a
    = Print t (Model c t v a)
    | Read c (v -> Model c t v a)
    | Pure a



-- Monad Instances


{-| Construct scenario with any state.
-}
succeed : a -> Model c t v a
succeed =
    Pure


{-| Combine two scenarios to make one scenario.
-}
andThen : (a -> Model c t v b) -> Model c t v a -> Model c t v b
andThen f s =
    case s of
        Print c next ->
            Print c (next |> andThen f)

        Read c g ->
            Read c (\v -> (g v |> andThen f))

        Pure a ->
            f a


{-| Similar to `andThen`, but ignores previous state.
-}
andAlways : Model c t v b -> Model c t v a -> Model c t v b
andAlways s2 =
    andThen (always s2)


{-| Convert scenario state by given function.
-}
map : (a -> b) -> Model c t v a -> Model c t v b
map f m =
    m |> andThen (succeed << f)



-- Constructors for `Scenario` type


{-| Construct scenario contains only one print message event.
-}
print : t -> Model c t v ()
print conf =
    Print conf <| succeed ()


{-| Construct scenario contains only one read input event.
-}
read : c -> Model c t v v
read c =
    Read c <| succeed



-- Configuration


{-| Configuration for running scenario
-}
type StepConfig x c t v
    = StepConfig
        { handlePrint : t -> x
        , handleEnd : x
        , updateReadConfig : c -> x
        }


{-| Constructor for `StepConfig`
-}
stepConfig :
  { handlePrint : t -> x
  , handleEnd : x
  , updateReadConfig : c -> x
  } -> StepConfig x c t v
stepConfig = StepConfig



-- Run Model DSL


{-| Run scenario step by step.
-}
step : StepConfig x c t v -> Model c t v a -> (Model c t v a, x)
step (StepConfig config) scenario =
    case scenario of
        Print t next ->
            ( next, config.handlePrint t )

        Read c f ->
            ( scenario, config.updateReadConfig c )

        Pure _ ->
            ( scenario, config.handleEnd )


{-| Push answer to a scenario and get next scenario
-}
pushAnswer : v -> Model c t v a -> Model c t v a
pushAnswer v scenario =
    case scenario of
        Read _ f ->
            f v

        _ ->
            scenario
