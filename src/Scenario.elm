module Scenario
    exposing
        ( Scenario
        , print
        , read
        , andThen
        , andAlways
        , update
        , Config
        , config
        , pushAnswer
        , succeed
        , map
        )

{-| A type safe DSL for CLI or Conversational User Interface.

# Common Types

@docs Scenario

# Convenient functions to construct scenario

@docs print
@docs read
@docs andThen
@docs andAlways

# Functions to run scenario model

@docs update
@docs pushAnswer

# Configurations for running scenario

@docs Config
@docs config

# Rarely used but important functions

@docs succeed
@docs map
-}


{-| Main type of this module to represent scenario.
-}
type Scenario c t v a
    = Print t (Scenario c t v a)
    | Read c (v -> Scenario c t v a)
    | Pure a



-- Monad Instances


{-| Construct scenario with any state.
-}
succeed : a -> Scenario c t v a
succeed =
    Pure


{-| Combine two scenarios to make one scenario.
-}
andThen : (a -> Scenario c t v b) -> Scenario c t v a -> Scenario c t v b
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
andAlways : Scenario c t v b -> Scenario c t v a -> Scenario c t v b
andAlways s2 =
    andThen (always s2)


{-| Convert scenario state by given function.
-}
map : (a -> b) -> Scenario c t v a -> Scenario c t v b
map f m =
    m |> andThen (succeed << f)



-- Constructors for `Scenario` type


{-| Construct scenario contains only one print message event.
-}
print : t -> Scenario c t v ()
print conf =
    Print conf <| succeed ()


{-| Construct scenario contains only one read input event.
-}
read : c -> Scenario c t v v
read c =
    Read c <| succeed



-- Configuration


{-| Configuration for running scenario
-}
type Config msg c t v
    = Config
        { handlePrint : t -> Cmd msg
        , handleEnd : Cmd msg
        , askRead : c -> Cmd msg
        }


{-| Constructor for `Config`
-}
config : (t -> Cmd msg) -> Cmd msg -> (c -> Cmd msg) -> Config msg c t v
config p e r =
    Config
        { handlePrint = p
        , handleEnd = e
        , askRead = r
        }



-- Run Scenario DSL


{-| Run scenario step by step.
-}
update : Config msg c t v -> Scenario c t v a -> ( Scenario c t v a, Cmd msg )
update (Config config) scenario =
    case scenario of
        Print t next ->
            ( next, config.handlePrint t )

        Read c f ->
            ( scenario, config.askRead c )

        Pure _ ->
            ( scenario, config.handleEnd )


{-| Push answer to a scenario and get next scenario
-}
pushAnswer : v -> Scenario c t v a -> Scenario c t v a
pushAnswer v scenario =
    case scenario of
        Read _ f ->
            f v

        _ ->
            scenario
