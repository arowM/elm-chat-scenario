module Chat.Types
  exposing
    ( ReadValue
    , ImageSrc
    , Label
    , Name
    , Namespace
    )

{-| Shared types for CUI.

# Aliases

@docs ReadValue
@docs ImageSrc
@docs Label
@docs Name
@docs Namespace
-}


{-| An alias of `String` for readability.
-}
type alias ReadValue =
  String


{-| An alias of `String` for readability.
-}
type alias ImageSrc =
  String


{-| An alias of `String` for readability.
-}
type alias Label =
  String


{-| An alias of `String` for readability.
-}
type alias Name =
  String


{-| An alias for `String` representing css namespace.
-}
type alias Namespace =
  String
