module RegExp exposing
  ( RegExp
  , fromString
  , fromStringWith
  , Options
  , never
  , contains
  , split
  , find
  , replace
  , Match
  , splitAtMost
  , findAtMost
  , replaceAtMost
  )


{-| A library for working with regular expressions. It uses [the
same kind of regular expressions accepted by JavaScript][js].

[js]: https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions

# Create
@docs RegExp, fromString, fromStringWith, Options, never

# Use
@docs contains, split, find, replace, Match

# Fancier Uses
@docs splitAtMost, findAtMost, replaceAtMost

-}


import Elm.Kernel.RegExp



-- CREATE


{-| A regular expression [as specified in JavaScript][js].

[js]: https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions

-}
type RegExp = RegExp


{-| Try to create a `RegExp`. Not all strings are valid though, so you get a
`Result' back. This means you can safely accept input from users.

    import RegExp

    lowerCase : RegExp.RegExp
    lowerCase =
      Maybe.withDefault RegExp.never <|
        RegExp.fromString "[a-z]+"

**Note:** There are some [shorthand character classes][short] like `\w` for
word characters, `\s` for whitespace characters, and `\d` for digits. **Make
sure they are properly escaped!** If you specify them directly in your code,
they would look like `"\\w\\s\\d"`.

[short]: http://www.regular-expressions.info/shorthand.html
-}
fromString : String -> Maybe RegExp
fromString string =
  fromStringWith { caseInsensitive = False, multiline = False } string


{-| Create a `RegExp` with some additional options. For example, you can define
`fromString` like this:

    import RegExp

    fromString : String -> Maybe RegExp.RegExp
    fromString string =
      fromStringWith { caseInsensitive = False, multiline = False } string

-}
fromStringWith : Options -> String -> Maybe RegExp
fromStringWith =
  Elm.Kernel.RegExp.fromStringWith


{-|-}
type alias Options =
  { caseInsensitive : Bool
  , multiline : Bool
  }


{-| A regular expression that never matches any string.
-}
never : RegExp
never =
  Elm.Kernel.RegExp.never



-- USE


{-| Check to see if a RegExp is contained in a string.

    import RegExp

    digit : RegExp.RegExp
    digit =
      Maybe.withDefault RegExp.never <|
        RegExp.fromString "[0-9]"

    -- RegExp.contains digit "abc123" == True
    -- RegExp.contains digit "abcxyz" == False
-}
contains : RegExp -> String -> Bool
contains =
  Elm.Kernel.RegExp.contains


{-| Split a string. The following example will split on commas and tolerate
whitespace on either side of the comma:

    import RegExp

    comma : RegExp.RegExp
    comma =
      Maybe.withDefault RegExp.never <|
        RegExp.fromString " *, *"

    -- RegExp.split comma "tom,99,90,85"     == ["tom","99","90","85"]
    -- RegExp.split comma "tom, 99, 90, 85"  == ["tom","99","90","85"]
    -- RegExp.split comma "tom , 99, 90, 85" == ["tom","99","90","85"]

If you want some really fancy splits, a library like
[elm-lang/parser][parser] will probably be easier to use.

[parser]: http://package.elm-lang.org/packages/elm-lang/parser/latest
-}
split : RegExp -> String -> List String
split =
  Elm.Kernel.RegExp.splitAtMost Elm.Kernel.RegExp.infinity


{-| Find matches in a string:

    import RegExp

    location : RegExp.RegExp
    location =
      Maybe.withDefault RegExp.never <|
        RegExp.fromString "[oi]n a (\\w+)"

    places : List RegExp.Match
    places =
      RegExp.find location "I am on a boat in a lake."

    -- map .match      places == [ "on a boat", "in a lake" ]
    -- map .submatches places == [ [Just "boat"], [Just "lake"] ]

If you need `submatches` for some reason, a library like
[elm-lang/parser][parser] will probably lead to better code in the long run.

[parser]: http://package.elm-lang.org/packages/elm-lang/parser/latest
-}
find : RegExp -> String -> List Match
find =
  Elm.Kernel.RegExp.findAtMost Elm.Kernel.RegExp.infinity


{-| The details about a particular match:

  * `match` &mdash; the full string of the match.
  * `index` &mdash; the index of the match in the original string.
  * `number` &mdash; if you find many matches, you can think of each one
    as being labeled with a `number` starting at one. So the first time you
    find a match, that is match `number` one. Second time is match `number` two.
    This is useful when paired with `replace` if replacement is dependent on how
    many times a pattern has appeared before.
  * `submatches` &mdash; a `RegExp` can have [subpatterns][sub], sup-parts that
    are in parentheses. This is a list of all these submatches. This is kind of
    garbage to use, and using a package like [elm-lang/parser][parser] is
    probably easier.

[sub]: https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions#Using_Parenthesized_Substring_Matches
[parser]: http://package.elm-lang.org/packages/elm-lang/parser/latest

-}
type alias Match =
  { match : String
  , index : Int
  , number : Int
  , submatches : List (Maybe String)
  }


{-| Replace matches. The function from `Match` to `String` lets
you use the details of a specific match when making replacements.

    import RegExp

    userReplace : String -> (RegExp.Match -> String) -> String -> String
    userReplace userRegExp replacer string =
      case RegExp.fromString userRegExp of
        Nothing ->
          string

        Just regexp ->
          RegExp.replace regexp replacer string

    devowel : String -> String
    devowel string =
      userReplace "[aeiou]" (\_ -> "") string

    -- devowel "The quick brown fox" == "Th qck brwn fx"

    reverseWords : String -> String
    reverseWords string =
      userReplace "\\w+" (.match >> String.reverse) string

    -- reverseWords "deliver mined parts" == "reviled denim strap"
-}
replace : RegExp -> (Match -> String) -> String -> String
replace =
  Elm.Kernel.RegExp.replace Elm.Kernel.RegExp.infinity



-- AT MOST


{-| Just like `split` but it stops after some number of matches.

A library like [elm-lang/parser][parser] will probably lead to better code in
the long run.

[parser]: http://package.elm-lang.org/packages/elm-lang/parser/latest-}
splitAtMost : Int -> RegExp -> String -> List String
splitAtMost =
  Elm.Kernel.RegExp.splitAtMost


{-| Just like `find` but it stops after some number of matches.

A library like [elm-lang/parser][parser] will probably lead to better code in
the long run.

[parser]: http://package.elm-lang.org/packages/elm-lang/parser/latest
-}
findAtMost : Int -> RegExp -> String -> List Match
findAtMost =
  Elm.Kernel.RegExp.findAtMost


{-| Just like `replace` but it stops after some number of matches.

A library like [elm-lang/parser][parser] will probably lead to better code in
the long run.

[parser]: http://package.elm-lang.org/packages/elm-lang/parser/latest
-}
replaceAtMost : Int -> RegExp -> String -> List Match
replaceAtMost =
  Elm.Kernel.RegExp.replaceAtMost