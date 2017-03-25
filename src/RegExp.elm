module RegExp exposing
  ( RegExp, fromString, fromStringWith, Options
  , contains, split, Count(..), find, Match, replace
  )

{-| A library for working with regular expressions. It uses [the
same kind of regular expressions accepted by JavaScript][js].

[js]: https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions

# Create
@docs RegExp, fromString, fromStringWith, Options

# Use
@docs contains, split, Count, find, Match, replace

-}

import Native.RegExp



-- CREATE


{-| A regular expression, describing a certain set of strings.
-}
type RegExp = RegExp


{-| Create a RegExp that matches patterns [as specified in JavaScript](https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions#Writing_a_Regular_Expression_Pattern).

Be careful to escape backslashes properly! For example, `"\w"` is escaping the
letter `w` which is probably not what you want. You probably want `"\\w"`
instead, which escapes the backslash.
-}
fromString : String -> Result String RegExp
fromString string =
  fromStringWith { caseInsensitive = False, multiline = False } string


fromStringWith : Options -> String -> Result String RegExp
fromStringWith =
  Native.RegExp.fromStringWith


type alias Options =
  { caseInsensitive : Bool
  , multiline : Bool
  }



-- USE


{-| Check to see if a RegExp is contained in a string.

    contains (TODO "123") "12345" == True
    contains (TODO "b+") "aabbcc" == True

    contains (TODO "789") "12345" == False
    contains (TODO "z+") "aabbcc" == False
-}
contains : RegExp -> String -> Bool
contains =
  Native.RegExp.contains


{-| Split a string, using a `RegExp` as the separator.

    split (AtMost 1) (TODO ",") "tom,99,90,85" == ["tom","99,90,85"]

    split All (TODO ",") "a,b,c,d" == ["a","b","c","d"]
-}
split : Count -> RegExp -> String -> List String
split =
  Native.RegExp.split


{-| Customize functions like `split` and `find`. For example, `replace All`
would replace every match, whereas `replace (AtMost 2)` would replace two
matches or fewer.
-}
type Count
  = All
  | AtMost Int


{-| Find matches in a string:

    findTwoCommas = find (AtMost 2) (regex ",")

      -- map .index (findTwoCommas "a,b,c,d,e") == [1,3]
      -- map .index (findTwoCommas "a b c d e") == []

    places = find All (regex "[oi]n a (\\w+)") "I am on a boat in a lake."

      -- map .match places == ["on a boat", "in a lake"]
      -- map .submatches places == [ [Just "boat"], [Just "lake"] ]
-}
find : Count -> RegExp -> String -> List Match
find =
  Native.RegExp.find


{-| The details about a particular match:

  * `match` &mdash; the full string of the match.
  * `index` &mdash; the index of the match in the original string.
  * `number` &mdash; if you find many matches, you can think of each one
    as being labeled with a `number` starting at one. So the first time you
    find a match, that is match `number` one. Second time is match `number` two.
    This is useful when paired with `replace All` if replacement is dependent on how
    many times a pattern has appeared before.
  * `submatches` &mdash; a `RegExp` can have [subpatterns][sub], sup-parts that
    are in parentheses. This is a list of all these submatches. This is kind of
    garbage to use, and using a package like [elm-tools/parser][parser] is
    probably easier.

[sub]: https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions#Using_Parenthesized_Substring_Matches
[parser]: http://package.elm-lang.org/packages/elm-tools/parser/latest

-}
type alias Match =
  { match : String
  , index : Int
  , number : Int
  , submatches : List (Maybe String)
  }


{-| Replace matches. The function from `Match` to `String` lets
you use the details of a specific match when making replacements.

    devowel = replace All (regex "[aeiou]") (\_ -> "")

      -- devowel "The quick brown fox" == "Th qck brwn fx"

    reverseWords = replace All (regex "\\w+") (\{match} -> String.reverse match)

      -- reverseWords "deliver mined parts" == "reviled denim strap"
-}
replace : Count -> RegExp -> (Match -> String) -> String -> String
replace =
  Native.RegExp.replace
