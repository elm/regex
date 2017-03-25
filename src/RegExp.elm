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


{-| A regular expression [as specified in JavaScript][js].

[js]: https://developer.mozilla.org/en/docs/Web/JavaScript/Guide/Regular_Expressions

-}
type RegExp = RegExp


{-| Try to create a `RegExp`. Not all strings are valid though, so you get a
`Result' back. This means you can safely accept input from users.

There are some [shorthand character classes][short] like `\w` for word
characters, `\s` for whitespace characters, and `\d` for digits. **Make sure
they are properly escaped!** If you specify them directly in your code, they
would look like `"\\w\\s\\d"`.

[short]: http://www.regular-expressions.info/shorthand.html
-}
fromString : String -> Result String RegExp
fromString string =
  fromStringWith { caseInsensitive = False, multiline = False } string


{-| Create a `RegExp` with some additional options.
-}
fromStringWith : Options -> String -> Result String RegExp
fromStringWith =
  Native.RegExp.fromStringWith


{-|-}
type alias Options =
  { caseInsensitive : Bool
  , multiline : Bool
  }



-- USE


{-| Check to see if a RegExp is contained in a string.

    import RegExp

    myContains : String -> String -> Bool
    myContains userRegExp string =
      case RegExp.fromString userRegExp of
        Err _ ->
          False

        Ok re ->
          RegExp.contains re string

    -- myContains "123" "12345" == True
    -- myContains "789" "12345" == False

    -- myContains "b+" "aabbcc" == True
    -- myContains "z+" "aabbcc" == False
-}
contains : RegExp -> String -> Bool
contains =
  Native.RegExp.contains


{-| Split a string, using a `RegExp` as the separator.

    import RegExp

    mySplit : Count -> String -> String -> List String
    mySplit count userRegExp string =
      case RegExp.fromString userRegExp of
        Err _ ->
          []

        Ok re ->
          RegExp.split count re string

    -- mySplit (AtMost 1) "|" "tom|99|90|85" == ["tom","99|90|85"]
    -- mySplit All        "|" "tom|99|90|85" == ["tom","99","90","85"]

If you want some really fancy splits, a library like
[elm-tools/parser][parser] will probably be easier to use.

[parser]: http://package.elm-lang.org/packages/elm-tools/parser/latest
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

    import RegExp

    myFind : Count -> String -> String -> List RegExp.Match
    myFind count userRegExp string =
      case RegExp.fromString userRegExp of
        Err _ ->
          []

        Ok re ->
          RegExp.find count re string

    findTwoCommas : String -> List RegExp.Match
    findTwoCommas string =
      myFind (AtMost 2) "," string

    -- List.map .index (findTwoCommas "a,b,c,d,e") == [1,3]
    -- List.map .index (findTwoCommas "a b c d e") == []

    places : List RegExp.Match
    places =
      myFind All "[oi]n a (\\w+)" "I am on a boat in a lake."

    -- map .match      places == [ "on a boat", "in a lake" ]
    -- map .submatches places == [ [Just "boat"], [Just "lake"] ]

If you need `submatches` for some reason, a library like
[elm-tools/parser][parser] will probably lead to better code in the long run.

[parser]: http://package.elm-lang.org/packages/elm-tools/parser/latest
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

    import RegExp

    myReplace : Count -> String -> (RegExp.Match -> String) -> String -> String
    myReplace count userRegExp replacer string =
      case RegExp.fromString userRegExp of
        Err _ ->
          string

        Ok re ->
          RegExp.replace count re replacer string

    devowel : String -> String
    devowel string =
      myReplace All "[aeiou]" (\_ -> "") string

    -- devowel "The quick brown fox" == "Th qck brwn fx"

    reverseWords : String -> String
    reverseWords string =
      myReplace All "\\w+" (.match >> String.reverse) string

    -- reverseWords "deliver mined parts" == "reviled denim strap"
-}
replace : Count -> RegExp -> (Match -> String) -> String -> String
replace =
  Native.RegExp.replace
