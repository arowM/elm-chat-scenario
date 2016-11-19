module Scenario
    exposing
        ( Scenario
        , succeed
        , andThen
        , andAlways
        , map
        , print
        , read
        )

{-| A type safe DSL for CLI or Conversational User Interface.

# Common Types

@docs Scenario

# Convenient functions to construct scenario

@docs print
@docs read
@docs andThen
@docs andAlways

# Rarely used but important functions

@docs succeed
@docs map
-}


{-| Main type of this module to represent scenario.
-}
type Scenario t v a
    = Print t (Scenario t v a)
    | Read (v -> Scenario t v a)
    | Pure a



-- Monad Instances


{-| Construct scenario with any state.
-}
succeed : a -> Scenario t v a
succeed =
    Pure


{-| Combine two scenarios to make one scenario.
-}
andThen : (a -> Scenario t v b) -> Scenario t v a -> Scenario t v b
andThen f s =
    case s of
        Print c next ->
            Print c (next |> andThen f)

        Read g ->
            Read (\v -> (g v |> andThen f))

        Pure a ->
            f a


{-| Similar to `andThen`, but ignores previous state.
-}
andAlways : Scenario t v a -> Scenario t v b -> Scenario t v b
andAlways s1 s2 =
    s1 |> andThen (always s2)


{-| Convert scenario state by given function.
-}
map : (a -> b) -> Scenario t v a -> Scenario t v b
map f m =
    m |> andThen (succeed << f)



-- Constructors for `Scenario` type


{-| Construct scenario contains only one talk script.
-}
print : t -> Scenario t v ()
print conf =
    Print conf <| succeed ()


{-| Construct scenario contains only one choice event.
-}
read : Scenario t v v
read =
    Read <| succeed
