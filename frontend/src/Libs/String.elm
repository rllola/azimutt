module Libs.String exposing
    ( capitalize
    , ellipsis
    , filterStartsWith
    , hashCode
    , inflect
    , nonEmpty
    , nonEmptyMaybe
    , orElse
    , plural
    , pluralize
    , pluralizeD
    , pluralizeL
    , pluralizeS
    , prepend
    , singular
    , slugify
    , splitWords
    , stripLeft
    , stripRight
    , unique
    )

import Dict exposing (Dict)
import Libs.List as List
import Libs.Maybe as Maybe
import Libs.Regex as Regex
import MD5
import Set exposing (Set)


nonEmpty : String -> Bool
nonEmpty string =
    string /= ""


nonEmptyMaybe : String -> Maybe String
nonEmptyMaybe str =
    if str == "" then
        Nothing

    else
        Just str


prepend : String -> String -> String
prepend prefix str =
    prefix ++ str


stripLeft : String -> String -> String
stripLeft prefix str =
    if str |> String.startsWith prefix then
        str |> String.dropLeft (String.length prefix)

    else
        str


stripRight : String -> String -> String
stripRight suffix str =
    if str |> String.endsWith suffix then
        str |> String.dropRight (String.length suffix)

    else
        str


ellipsis : Int -> String -> String
ellipsis maxLen str =
    if String.length str <= maxLen then
        str

    else
        str |> String.left maxLen |> String.dropRight 3 |> (\s -> s ++ "...")


capitalize : String -> String
capitalize str =
    str
        |> String.toList
        |> List.indexedMap
            (\i c ->
                if i == 0 then
                    Char.toUpper c

                else
                    Char.toLower c
            )
        |> String.fromList


orElse : String -> String -> String
orElse other str =
    if str == "" then
        other

    else
        str


filterStartsWith : String -> String -> String
filterStartsWith prefix str =
    if str |> String.startsWith prefix then
        str

    else
        ""


splitWords : String -> List String
splitWords text =
    let
        ( rest, results ) =
            text
                |> String.toList
                |> List.foldl
                    (\c ( acc, res ) ->
                        if c |> Char.isAlphaNum |> not then
                            ( [], acc :: res )

                        else if Char.isUpper c && (acc |> List.head |> Maybe.all Char.isUpper |> not) then
                            ( [ c ], acc :: res )

                        else
                            ( c :: acc, res )
                    )
                    ( [], [] )
    in
    (rest :: results) |> List.filter List.nonEmpty |> List.reverse |> List.map (List.reverse >> String.fromList >> String.toLower)


hashCode : String -> Int
hashCode input =
    input |> MD5.hex |> String.toList |> List.foldl (\c code -> ((31 * code) + Char.toCode c) |> modBy maxSafeInteger) 7


maxSafeInteger : number
maxSafeInteger =
    2 ^ 53 - 1


unique : List String -> String -> String
unique takenIds id =
    if takenIds |> List.any (\taken -> taken == id) then
        case id |> Regex.matches "^(.*?)([0-9]+)?(\\.[a-z]+)?$" of
            (Just prefix) :: num :: extension :: [] ->
                unique
                    takenIds
                    (prefix
                        ++ (num |> Maybe.andThen String.toInt |> Maybe.mapOrElse (\n -> n + 1) 2 |> String.fromInt)
                        ++ (extension |> Maybe.withDefault "")
                    )

            _ ->
                id ++ "-err"

    else
        id


inflect : String -> String -> String -> Int -> String
inflect none one many count =
    if count == 0 then
        none

    else if count == 1 then
        one

    else
        many


plural : String -> String
plural word =
    -- trivial pluralize that works only for usual words, use `inflect` for more flexibility
    if String.endsWith "y" word && not (String.endsWith "ay" word || String.endsWith "ey" word || String.endsWith "oy" word || String.endsWith "uy" word) then
        (word |> String.dropRight 1) ++ "ies"

    else if String.endsWith "s" word || String.endsWith "x" word || String.endsWith "z" word || String.endsWith "sh" word || String.endsWith "ch" word then
        word ++ "es"

    else
        word ++ "s"


pluralize : String -> Int -> String
pluralize word count =
    count |> inflect ("0 " ++ word) ("1 " ++ word) (String.fromInt count ++ " " ++ plural word)


pluralizeL : String -> List a -> String
pluralizeL word list =
    list |> List.length |> pluralize word


pluralizeS : String -> Set a -> String
pluralizeS word set =
    set |> Set.size |> pluralize word


pluralizeD : String -> Dict k a -> String
pluralizeD word list =
    list |> Dict.size |> pluralize word


singular : String -> String
singular word =
    if word |> String.endsWith "ies" then
        (word |> String.dropRight 3) ++ "y"

    else if word |> String.endsWith "es" then
        word |> String.dropRight 2

    else if word |> String.endsWith "s" then
        word |> String.dropRight 1

    else
        word


slugify : String -> String
slugify str =
    str
        |> String.toLower
        |> String.toList
        |> List.map
            (\c ->
                if Char.isLower c || Char.isDigit c then
                    c |> String.fromChar

                else
                    diacritics |> Dict.get c |> Maybe.withDefault "-"
            )
        |> String.join ""
        |> Regex.replace "-+" "-"
        |> stripLeft "-"
        |> stripRight "-"


diacritics : Dict Char String
diacritics =
    [ ( 'A', "A" )
    , ( 'Ⓐ', "A" )
    , ( 'Ａ', "A" )
    , ( 'À', "A" )
    , ( 'Á', "A" )
    , ( 'Â', "A" )
    , ( 'Ầ', "A" )
    , ( 'Ấ', "A" )
    , ( 'Ẫ', "A" )
    , ( 'Ẩ', "A" )
    , ( 'Ã', "A" )
    , ( 'Ā', "A" )
    , ( 'Ă', "A" )
    , ( 'Ằ', "A" )
    , ( 'Ắ', "A" )
    , ( 'Ẵ', "A" )
    , ( 'Ẳ', "A" )
    , ( 'Ȧ', "A" )
    , ( 'Ǡ', "A" )
    , ( 'Ä', "A" )
    , ( 'Ǟ', "A" )
    , ( 'Ả', "A" )
    , ( 'Å', "A" )
    , ( 'Ǻ', "A" )
    , ( 'Ǎ', "A" )
    , ( 'Ȁ', "A" )
    , ( 'Ȃ', "A" )
    , ( 'Ạ', "A" )
    , ( 'Ậ', "A" )
    , ( 'Ặ', "A" )
    , ( 'Ḁ', "A" )
    , ( 'Ą', "A" )
    , ( 'Ⱥ', "A" )
    , ( 'Ɐ', "A" )
    , ( 'Ꜳ', "AA" )
    , ( 'Æ', "AE" )
    , ( 'Ǽ', "AE" )
    , ( 'Ǣ', "AE" )
    , ( 'Ꜵ', "AO" )
    , ( 'Ꜷ', "AU" )
    , ( 'Ꜹ', "AV" )
    , ( 'Ꜻ', "AV" )
    , ( 'Ꜽ', "AY" )
    , ( 'B', "B" )
    , ( 'Ⓑ', "B" )
    , ( 'Ｂ', "B" )
    , ( 'Ḃ', "B" )
    , ( 'Ḅ', "B" )
    , ( 'Ḇ', "B" )
    , ( 'Ƀ', "B" )
    , ( 'Ƃ', "B" )
    , ( 'Ɓ', "B" )
    , ( 'C', "C" )
    , ( 'Ⓒ', "C" )
    , ( 'Ｃ', "C" )
    , ( 'Ć', "C" )
    , ( 'Ĉ', "C" )
    , ( 'Ċ', "C" )
    , ( 'Č', "C" )
    , ( 'Ç', "C" )
    , ( 'Ḉ', "C" )
    , ( 'Ƈ', "C" )
    , ( 'Ȼ', "C" )
    , ( 'Ꜿ', "C" )
    , ( 'D', "D" )
    , ( 'Ⓓ', "D" )
    , ( 'Ｄ', "D" )
    , ( 'Ḋ', "D" )
    , ( 'Ď', "D" )
    , ( 'Ḍ', "D" )
    , ( 'Ḑ', "D" )
    , ( 'Ḓ', "D" )
    , ( 'Ḏ', "D" )
    , ( 'Đ', "D" )
    , ( 'Ƌ', "D" )
    , ( 'Ɗ', "D" )
    , ( 'Ɖ', "D" )
    , ( 'Ꝺ', "D" )
    , ( 'Ǳ', "DZ" )
    , ( 'Ǆ', "DZ" )
    , ( 'ǲ', "Dz" )
    , ( 'ǅ', "Dz" )
    , ( 'E', "E" )
    , ( 'Ⓔ', "E" )
    , ( 'Ｅ', "E" )
    , ( 'È', "E" )
    , ( 'É', "E" )
    , ( 'Ê', "E" )
    , ( 'Ề', "E" )
    , ( 'Ế', "E" )
    , ( 'Ễ', "E" )
    , ( 'Ể', "E" )
    , ( 'Ẽ', "E" )
    , ( 'Ē', "E" )
    , ( 'Ḕ', "E" )
    , ( 'Ḗ', "E" )
    , ( 'Ĕ', "E" )
    , ( 'Ė', "E" )
    , ( 'Ë', "E" )
    , ( 'Ẻ', "E" )
    , ( 'Ě', "E" )
    , ( 'Ȅ', "E" )
    , ( 'Ȇ', "E" )
    , ( 'Ẹ', "E" )
    , ( 'Ệ', "E" )
    , ( 'Ȩ', "E" )
    , ( 'Ḝ', "E" )
    , ( 'Ę', "E" )
    , ( 'Ḙ', "E" )
    , ( 'Ḛ', "E" )
    , ( 'Ɛ', "E" )
    , ( 'Ǝ', "E" )
    , ( 'F', "F" )
    , ( 'Ⓕ', "F" )
    , ( 'Ｆ', "F" )
    , ( 'Ḟ', "F" )
    , ( 'Ƒ', "F" )
    , ( 'Ꝼ', "F" )
    , ( 'G', "G" )
    , ( 'Ⓖ', "G" )
    , ( 'Ｇ', "G" )
    , ( 'Ǵ', "G" )
    , ( 'Ĝ', "G" )
    , ( 'Ḡ', "G" )
    , ( 'Ğ', "G" )
    , ( 'Ġ', "G" )
    , ( 'Ǧ', "G" )
    , ( 'Ģ', "G" )
    , ( 'Ǥ', "G" )
    , ( 'Ɠ', "G" )
    , ( 'Ꞡ', "G" )
    , ( 'Ᵹ', "G" )
    , ( 'Ꝿ', "G" )
    , ( 'H', "H" )
    , ( 'Ⓗ', "H" )
    , ( 'Ｈ', "H" )
    , ( 'Ĥ', "H" )
    , ( 'Ḣ', "H" )
    , ( 'Ḧ', "H" )
    , ( 'Ȟ', "H" )
    , ( 'Ḥ', "H" )
    , ( 'Ḩ', "H" )
    , ( 'Ḫ', "H" )
    , ( 'Ħ', "H" )
    , ( 'Ⱨ', "H" )
    , ( 'Ⱶ', "H" )
    , ( 'Ɥ', "H" )
    , ( 'I', "I" )
    , ( 'Ⓘ', "I" )
    , ( 'Ｉ', "I" )
    , ( 'Ì', "I" )
    , ( 'Í', "I" )
    , ( 'Î', "I" )
    , ( 'Ĩ', "I" )
    , ( 'Ī', "I" )
    , ( 'Ĭ', "I" )
    , ( 'İ', "I" )
    , ( 'Ï', "I" )
    , ( 'Ḯ', "I" )
    , ( 'Ỉ', "I" )
    , ( 'Ǐ', "I" )
    , ( 'Ȉ', "I" )
    , ( 'Ȋ', "I" )
    , ( 'Ị', "I" )
    , ( 'Į', "I" )
    , ( 'Ḭ', "I" )
    , ( 'Ɨ', "I" )
    , ( 'J', "J" )
    , ( 'Ⓙ', "J" )
    , ( 'Ｊ', "J" )
    , ( 'Ĵ', "J" )
    , ( 'Ɉ', "J" )
    , ( 'K', "K" )
    , ( 'Ⓚ', "K" )
    , ( 'Ｋ', "K" )
    , ( 'Ḱ', "K" )
    , ( 'Ǩ', "K" )
    , ( 'Ḳ', "K" )
    , ( 'Ķ', "K" )
    , ( 'Ḵ', "K" )
    , ( 'Ƙ', "K" )
    , ( 'Ⱪ', "K" )
    , ( 'Ꝁ', "K" )
    , ( 'Ꝃ', "K" )
    , ( 'Ꝅ', "K" )
    , ( 'Ꞣ', "K" )
    , ( 'L', "L" )
    , ( 'Ⓛ', "L" )
    , ( 'Ｌ', "L" )
    , ( 'Ŀ', "L" )
    , ( 'Ĺ', "L" )
    , ( 'Ľ', "L" )
    , ( 'Ḷ', "L" )
    , ( 'Ḹ', "L" )
    , ( 'Ļ', "L" )
    , ( 'Ḽ', "L" )
    , ( 'Ḻ', "L" )
    , ( 'Ł', "L" )
    , ( 'Ƚ', "L" )
    , ( 'Ɫ', "L" )
    , ( 'Ⱡ', "L" )
    , ( 'Ꝉ', "L" )
    , ( 'Ꝇ', "L" )
    , ( 'Ꞁ', "L" )
    , ( 'Ǉ', "LJ" )
    , ( 'ǈ', "Lj" )
    , ( 'M', "M" )
    , ( 'Ⓜ', "M" )
    , ( 'Ｍ', "M" )
    , ( 'Ḿ', "M" )
    , ( 'Ṁ', "M" )
    , ( 'Ṃ', "M" )
    , ( 'Ɱ', "M" )
    , ( 'Ɯ', "M" )
    , ( 'N', "N" )
    , ( 'Ⓝ', "N" )
    , ( 'Ｎ', "N" )
    , ( 'Ǹ', "N" )
    , ( 'Ń', "N" )
    , ( 'Ñ', "N" )
    , ( 'Ṅ', "N" )
    , ( 'Ň', "N" )
    , ( 'Ṇ', "N" )
    , ( 'Ņ', "N" )
    , ( 'Ṋ', "N" )
    , ( 'Ṉ', "N" )
    , ( 'Ƞ', "N" )
    , ( 'Ɲ', "N" )
    , ( 'Ꞑ', "N" )
    , ( 'Ꞥ', "N" )
    , ( 'Ǌ', "NJ" )
    , ( 'ǋ', "Nj" )
    , ( 'O', "O" )
    , ( 'Ⓞ', "O" )
    , ( 'Ｏ', "O" )
    , ( 'Ò', "O" )
    , ( 'Ó', "O" )
    , ( 'Ô', "O" )
    , ( 'Ồ', "O" )
    , ( 'Ố', "O" )
    , ( 'Ỗ', "O" )
    , ( 'Ổ', "O" )
    , ( 'Õ', "O" )
    , ( 'Ṍ', "O" )
    , ( 'Ȭ', "O" )
    , ( 'Ṏ', "O" )
    , ( 'Ō', "O" )
    , ( 'Ṑ', "O" )
    , ( 'Ṓ', "O" )
    , ( 'Ŏ', "O" )
    , ( 'Ȯ', "O" )
    , ( 'Ȱ', "O" )
    , ( 'Ö', "O" )
    , ( 'Ȫ', "O" )
    , ( 'Ỏ', "O" )
    , ( 'Ő', "O" )
    , ( 'Ǒ', "O" )
    , ( 'Ȍ', "O" )
    , ( 'Ȏ', "O" )
    , ( 'Ơ', "O" )
    , ( 'Ờ', "O" )
    , ( 'Ớ', "O" )
    , ( 'Ỡ', "O" )
    , ( 'Ở', "O" )
    , ( 'Ợ', "O" )
    , ( 'Ọ', "O" )
    , ( 'Ộ', "O" )
    , ( 'Ǫ', "O" )
    , ( 'Ǭ', "O" )
    , ( 'Ø', "O" )
    , ( 'Ǿ', "O" )
    , ( 'Ɔ', "O" )
    , ( 'Ɵ', "O" )
    , ( 'Ꝋ', "O" )
    , ( 'Ꝍ', "O" )
    , ( 'Ƣ', "OI" )
    , ( 'Ꝏ', "OO" )
    , ( 'Ȣ', "OU" )
    , ( '\u{008C}', "OE" )
    , ( 'Œ', "OE" )
    , ( '\u{009C}', "oe" )
    , ( 'œ', "oe" )
    , ( 'P', "P" )
    , ( 'Ⓟ', "P" )
    , ( 'Ｐ', "P" )
    , ( 'Ṕ', "P" )
    , ( 'Ṗ', "P" )
    , ( 'Ƥ', "P" )
    , ( 'Ᵽ', "P" )
    , ( 'Ꝑ', "P" )
    , ( 'Ꝓ', "P" )
    , ( 'Ꝕ', "P" )
    , ( 'Q', "Q" )
    , ( 'Ⓠ', "Q" )
    , ( 'Ｑ', "Q" )
    , ( 'Ꝗ', "Q" )
    , ( 'Ꝙ', "Q" )
    , ( 'Ɋ', "Q" )
    , ( 'R', "R" )
    , ( 'Ⓡ', "R" )
    , ( 'Ｒ', "R" )
    , ( 'Ŕ', "R" )
    , ( 'Ṙ', "R" )
    , ( 'Ř', "R" )
    , ( 'Ȑ', "R" )
    , ( 'Ȓ', "R" )
    , ( 'Ṛ', "R" )
    , ( 'Ṝ', "R" )
    , ( 'Ŗ', "R" )
    , ( 'Ṟ', "R" )
    , ( 'Ɍ', "R" )
    , ( 'Ɽ', "R" )
    , ( 'Ꝛ', "R" )
    , ( 'Ꞧ', "R" )
    , ( 'Ꞃ', "R" )
    , ( 'S', "S" )
    , ( 'Ⓢ', "S" )
    , ( 'Ｓ', "S" )
    , ( 'ẞ', "S" )
    , ( 'Ś', "S" )
    , ( 'Ṥ', "S" )
    , ( 'Ŝ', "S" )
    , ( 'Ṡ', "S" )
    , ( 'Š', "S" )
    , ( 'Ṧ', "S" )
    , ( 'Ṣ', "S" )
    , ( 'Ṩ', "S" )
    , ( 'Ș', "S" )
    , ( 'Ş', "S" )
    , ( 'Ȿ', "S" )
    , ( 'Ꞩ', "S" )
    , ( 'Ꞅ', "S" )
    , ( 'T', "T" )
    , ( 'Ⓣ', "T" )
    , ( 'Ｔ', "T" )
    , ( 'Ṫ', "T" )
    , ( 'Ť', "T" )
    , ( 'Ṭ', "T" )
    , ( 'Ț', "T" )
    , ( 'Ţ', "T" )
    , ( 'Ṱ', "T" )
    , ( 'Ṯ', "T" )
    , ( 'Ŧ', "T" )
    , ( 'Ƭ', "T" )
    , ( 'Ʈ', "T" )
    , ( 'Ⱦ', "T" )
    , ( 'Ꞇ', "T" )
    , ( 'Ꜩ', "TZ" )
    , ( 'U', "U" )
    , ( 'Ⓤ', "U" )
    , ( 'Ｕ', "U" )
    , ( 'Ù', "U" )
    , ( 'Ú', "U" )
    , ( 'Û', "U" )
    , ( 'Ũ', "U" )
    , ( 'Ṹ', "U" )
    , ( 'Ū', "U" )
    , ( 'Ṻ', "U" )
    , ( 'Ŭ', "U" )
    , ( 'Ü', "U" )
    , ( 'Ǜ', "U" )
    , ( 'Ǘ', "U" )
    , ( 'Ǖ', "U" )
    , ( 'Ǚ', "U" )
    , ( 'Ủ', "U" )
    , ( 'Ů', "U" )
    , ( 'Ű', "U" )
    , ( 'Ǔ', "U" )
    , ( 'Ȕ', "U" )
    , ( 'Ȗ', "U" )
    , ( 'Ư', "U" )
    , ( 'Ừ', "U" )
    , ( 'Ứ', "U" )
    , ( 'Ữ', "U" )
    , ( 'Ử', "U" )
    , ( 'Ự', "U" )
    , ( 'Ụ', "U" )
    , ( 'Ṳ', "U" )
    , ( 'Ų', "U" )
    , ( 'Ṷ', "U" )
    , ( 'Ṵ', "U" )
    , ( 'Ʉ', "U" )
    , ( 'V', "V" )
    , ( 'Ⓥ', "V" )
    , ( 'Ｖ', "V" )
    , ( 'Ṽ', "V" )
    , ( 'Ṿ', "V" )
    , ( 'Ʋ', "V" )
    , ( 'Ꝟ', "V" )
    , ( 'Ʌ', "V" )
    , ( 'Ꝡ', "VY" )
    , ( 'W', "W" )
    , ( 'Ⓦ', "W" )
    , ( 'Ｗ', "W" )
    , ( 'Ẁ', "W" )
    , ( 'Ẃ', "W" )
    , ( 'Ŵ', "W" )
    , ( 'Ẇ', "W" )
    , ( 'Ẅ', "W" )
    , ( 'Ẉ', "W" )
    , ( 'Ⱳ', "W" )
    , ( 'X', "X" )
    , ( 'Ⓧ', "X" )
    , ( 'Ｘ', "X" )
    , ( 'Ẋ', "X" )
    , ( 'Ẍ', "X" )
    , ( 'Y', "Y" )
    , ( 'Ⓨ', "Y" )
    , ( 'Ｙ', "Y" )
    , ( 'Ỳ', "Y" )
    , ( 'Ý', "Y" )
    , ( 'Ŷ', "Y" )
    , ( 'Ỹ', "Y" )
    , ( 'Ȳ', "Y" )
    , ( 'Ẏ', "Y" )
    , ( 'Ÿ', "Y" )
    , ( 'Ỷ', "Y" )
    , ( 'Ỵ', "Y" )
    , ( 'Ƴ', "Y" )
    , ( 'Ɏ', "Y" )
    , ( 'Ỿ', "Y" )
    , ( 'Z', "Z" )
    , ( 'Ⓩ', "Z" )
    , ( 'Ｚ', "Z" )
    , ( 'Ź', "Z" )
    , ( 'Ẑ', "Z" )
    , ( 'Ż', "Z" )
    , ( 'Ž', "Z" )
    , ( 'Ẓ', "Z" )
    , ( 'Ẕ', "Z" )
    , ( 'Ƶ', "Z" )
    , ( 'Ȥ', "Z" )
    , ( 'Ɀ', "Z" )
    , ( 'Ⱬ', "Z" )
    , ( 'Ꝣ', "Z" )
    , ( 'a', "a" )
    , ( 'ⓐ', "a" )
    , ( 'ａ', "a" )
    , ( 'ẚ', "a" )
    , ( 'à', "a" )
    , ( 'á', "a" )
    , ( 'â', "a" )
    , ( 'ầ', "a" )
    , ( 'ấ', "a" )
    , ( 'ẫ', "a" )
    , ( 'ẩ', "a" )
    , ( 'ã', "a" )
    , ( 'ā', "a" )
    , ( 'ă', "a" )
    , ( 'ằ', "a" )
    , ( 'ắ', "a" )
    , ( 'ẵ', "a" )
    , ( 'ẳ', "a" )
    , ( 'ȧ', "a" )
    , ( 'ǡ', "a" )
    , ( 'ä', "a" )
    , ( 'ǟ', "a" )
    , ( 'ả', "a" )
    , ( 'å', "a" )
    , ( 'ǻ', "a" )
    , ( 'ǎ', "a" )
    , ( 'ȁ', "a" )
    , ( 'ȃ', "a" )
    , ( 'ạ', "a" )
    , ( 'ậ', "a" )
    , ( 'ặ', "a" )
    , ( 'ḁ', "a" )
    , ( 'ą', "a" )
    , ( 'ⱥ', "a" )
    , ( 'ɐ', "a" )
    , ( 'ꜳ', "aa" )
    , ( 'æ', "ae" )
    , ( 'ǽ', "ae" )
    , ( 'ǣ', "ae" )
    , ( 'ꜵ', "ao" )
    , ( 'ꜷ', "au" )
    , ( 'ꜹ', "av" )
    , ( 'ꜻ', "av" )
    , ( 'ꜽ', "ay" )
    , ( 'b', "b" )
    , ( 'ⓑ', "b" )
    , ( 'ｂ', "b" )
    , ( 'ḃ', "b" )
    , ( 'ḅ', "b" )
    , ( 'ḇ', "b" )
    , ( 'ƀ', "b" )
    , ( 'ƃ', "b" )
    , ( 'ɓ', "b" )
    , ( 'c', "c" )
    , ( 'ⓒ', "c" )
    , ( 'ｃ', "c" )
    , ( 'ć', "c" )
    , ( 'ĉ', "c" )
    , ( 'ċ', "c" )
    , ( 'č', "c" )
    , ( 'ç', "c" )
    , ( 'ḉ', "c" )
    , ( 'ƈ', "c" )
    , ( 'ȼ', "c" )
    , ( 'ꜿ', "c" )
    , ( 'ↄ', "c" )
    , ( 'd', "d" )
    , ( 'ⓓ', "d" )
    , ( 'ｄ', "d" )
    , ( 'ḋ', "d" )
    , ( 'ď', "d" )
    , ( 'ḍ', "d" )
    , ( 'ḑ', "d" )
    , ( 'ḓ', "d" )
    , ( 'ḏ', "d" )
    , ( 'đ', "d" )
    , ( 'ƌ', "d" )
    , ( 'ɖ', "d" )
    , ( 'ɗ', "d" )
    , ( 'ꝺ', "d" )
    , ( 'ǳ', "dz" )
    , ( 'ǆ', "dz" )
    , ( 'e', "e" )
    , ( 'ⓔ', "e" )
    , ( 'ｅ', "e" )
    , ( 'è', "e" )
    , ( 'é', "e" )
    , ( 'ê', "e" )
    , ( 'ề', "e" )
    , ( 'ế', "e" )
    , ( 'ễ', "e" )
    , ( 'ể', "e" )
    , ( 'ẽ', "e" )
    , ( 'ē', "e" )
    , ( 'ḕ', "e" )
    , ( 'ḗ', "e" )
    , ( 'ĕ', "e" )
    , ( 'ė', "e" )
    , ( 'ë', "e" )
    , ( 'ẻ', "e" )
    , ( 'ě', "e" )
    , ( 'ȅ', "e" )
    , ( 'ȇ', "e" )
    , ( 'ẹ', "e" )
    , ( 'ệ', "e" )
    , ( 'ȩ', "e" )
    , ( 'ḝ', "e" )
    , ( 'ę', "e" )
    , ( 'ḙ', "e" )
    , ( 'ḛ', "e" )
    , ( 'ɇ', "e" )
    , ( 'ɛ', "e" )
    , ( 'ǝ', "e" )
    , ( 'f', "f" )
    , ( 'ⓕ', "f" )
    , ( 'ｆ', "f" )
    , ( 'ḟ', "f" )
    , ( 'ƒ', "f" )
    , ( 'ꝼ', "f" )
    , ( 'g', "g" )
    , ( 'ⓖ', "g" )
    , ( 'ｇ', "g" )
    , ( 'ǵ', "g" )
    , ( 'ĝ', "g" )
    , ( 'ḡ', "g" )
    , ( 'ğ', "g" )
    , ( 'ġ', "g" )
    , ( 'ǧ', "g" )
    , ( 'ģ', "g" )
    , ( 'ǥ', "g" )
    , ( 'ɠ', "g" )
    , ( 'ꞡ', "g" )
    , ( 'ᵹ', "g" )
    , ( 'ꝿ', "g" )
    , ( 'h', "h" )
    , ( 'ⓗ', "h" )
    , ( 'ｈ', "h" )
    , ( 'ĥ', "h" )
    , ( 'ḣ', "h" )
    , ( 'ḧ', "h" )
    , ( 'ȟ', "h" )
    , ( 'ḥ', "h" )
    , ( 'ḩ', "h" )
    , ( 'ḫ', "h" )
    , ( 'ẖ', "h" )
    , ( 'ħ', "h" )
    , ( 'ⱨ', "h" )
    , ( 'ⱶ', "h" )
    , ( 'ɥ', "h" )
    , ( 'ƕ', "hv" )
    , ( 'i', "i" )
    , ( 'ⓘ', "i" )
    , ( 'ｉ', "i" )
    , ( 'ì', "i" )
    , ( 'í', "i" )
    , ( 'î', "i" )
    , ( 'ĩ', "i" )
    , ( 'ī', "i" )
    , ( 'ĭ', "i" )
    , ( 'ï', "i" )
    , ( 'ḯ', "i" )
    , ( 'ỉ', "i" )
    , ( 'ǐ', "i" )
    , ( 'ȉ', "i" )
    , ( 'ȋ', "i" )
    , ( 'ị', "i" )
    , ( 'į', "i" )
    , ( 'ḭ', "i" )
    , ( 'ɨ', "i" )
    , ( 'ı', "i" )
    , ( 'j', "j" )
    , ( 'ⓙ', "j" )
    , ( 'ｊ', "j" )
    , ( 'ĵ', "j" )
    , ( 'ǰ', "j" )
    , ( 'ɉ', "j" )
    , ( 'k', "k" )
    , ( 'ⓚ', "k" )
    , ( 'ｋ', "k" )
    , ( 'ḱ', "k" )
    , ( 'ǩ', "k" )
    , ( 'ḳ', "k" )
    , ( 'ķ', "k" )
    , ( 'ḵ', "k" )
    , ( 'ƙ', "k" )
    , ( 'ⱪ', "k" )
    , ( 'ꝁ', "k" )
    , ( 'ꝃ', "k" )
    , ( 'ꝅ', "k" )
    , ( 'ꞣ', "k" )
    , ( 'l', "l" )
    , ( 'ⓛ', "l" )
    , ( 'ｌ', "l" )
    , ( 'ŀ', "l" )
    , ( 'ĺ', "l" )
    , ( 'ľ', "l" )
    , ( 'ḷ', "l" )
    , ( 'ḹ', "l" )
    , ( 'ļ', "l" )
    , ( 'ḽ', "l" )
    , ( 'ḻ', "l" )
    , ( 'ſ', "l" )
    , ( 'ł', "l" )
    , ( 'ƚ', "l" )
    , ( 'ɫ', "l" )
    , ( 'ⱡ', "l" )
    , ( 'ꝉ', "l" )
    , ( 'ꞁ', "l" )
    , ( 'ꝇ', "l" )
    , ( 'ǉ', "lj" )
    , ( 'm', "m" )
    , ( 'ⓜ', "m" )
    , ( 'ｍ', "m" )
    , ( 'ḿ', "m" )
    , ( 'ṁ', "m" )
    , ( 'ṃ', "m" )
    , ( 'ɱ', "m" )
    , ( 'ɯ', "m" )
    , ( 'n', "n" )
    , ( 'ⓝ', "n" )
    , ( 'ｎ', "n" )
    , ( 'ǹ', "n" )
    , ( 'ń', "n" )
    , ( 'ñ', "n" )
    , ( 'ṅ', "n" )
    , ( 'ň', "n" )
    , ( 'ṇ', "n" )
    , ( 'ņ', "n" )
    , ( 'ṋ', "n" )
    , ( 'ṉ', "n" )
    , ( 'ƞ', "n" )
    , ( 'ɲ', "n" )
    , ( 'ŉ', "n" )
    , ( 'ꞑ', "n" )
    , ( 'ꞥ', "n" )
    , ( 'ǌ', "nj" )
    , ( 'o', "o" )
    , ( 'ⓞ', "o" )
    , ( 'ｏ', "o" )
    , ( 'ò', "o" )
    , ( 'ó', "o" )
    , ( 'ô', "o" )
    , ( 'ồ', "o" )
    , ( 'ố', "o" )
    , ( 'ỗ', "o" )
    , ( 'ổ', "o" )
    , ( 'õ', "o" )
    , ( 'ṍ', "o" )
    , ( 'ȭ', "o" )
    , ( 'ṏ', "o" )
    , ( 'ō', "o" )
    , ( 'ṑ', "o" )
    , ( 'ṓ', "o" )
    , ( 'ŏ', "o" )
    , ( 'ȯ', "o" )
    , ( 'ȱ', "o" )
    , ( 'ö', "o" )
    , ( 'ȫ', "o" )
    , ( 'ỏ', "o" )
    , ( 'ő', "o" )
    , ( 'ǒ', "o" )
    , ( 'ȍ', "o" )
    , ( 'ȏ', "o" )
    , ( 'ơ', "o" )
    , ( 'ờ', "o" )
    , ( 'ớ', "o" )
    , ( 'ỡ', "o" )
    , ( 'ở', "o" )
    , ( 'ợ', "o" )
    , ( 'ọ', "o" )
    , ( 'ộ', "o" )
    , ( 'ǫ', "o" )
    , ( 'ǭ', "o" )
    , ( 'ø', "o" )
    , ( 'ǿ', "o" )
    , ( 'ɔ', "o" )
    , ( 'ꝋ', "o" )
    , ( 'ꝍ', "o" )
    , ( 'ɵ', "o" )
    , ( 'ƣ', "oi" )
    , ( 'ȣ', "ou" )
    , ( 'ꝏ', "oo" )
    , ( 'p', "p" )
    , ( 'ⓟ', "p" )
    , ( 'ｐ', "p" )
    , ( 'ṕ', "p" )
    , ( 'ṗ', "p" )
    , ( 'ƥ', "p" )
    , ( 'ᵽ', "p" )
    , ( 'ꝑ', "p" )
    , ( 'ꝓ', "p" )
    , ( 'ꝕ', "p" )
    , ( 'q', "q" )
    , ( 'ⓠ', "q" )
    , ( 'ｑ', "q" )
    , ( 'ɋ', "q" )
    , ( 'ꝗ', "q" )
    , ( 'ꝙ', "q" )
    , ( 'r', "r" )
    , ( 'ⓡ', "r" )
    , ( 'ｒ', "r" )
    , ( 'ŕ', "r" )
    , ( 'ṙ', "r" )
    , ( 'ř', "r" )
    , ( 'ȑ', "r" )
    , ( 'ȓ', "r" )
    , ( 'ṛ', "r" )
    , ( 'ṝ', "r" )
    , ( 'ŗ', "r" )
    , ( 'ṟ', "r" )
    , ( 'ɍ', "r" )
    , ( 'ɽ', "r" )
    , ( 'ꝛ', "r" )
    , ( 'ꞧ', "r" )
    , ( 'ꞃ', "r" )
    , ( 's', "s" )
    , ( 'ⓢ', "s" )
    , ( 'ｓ', "s" )
    , ( 'ß', "s" )
    , ( 'ś', "s" )
    , ( 'ṥ', "s" )
    , ( 'ŝ', "s" )
    , ( 'ṡ', "s" )
    , ( 'š', "s" )
    , ( 'ṧ', "s" )
    , ( 'ṣ', "s" )
    , ( 'ṩ', "s" )
    , ( 'ș', "s" )
    , ( 'ş', "s" )
    , ( 'ȿ', "s" )
    , ( 'ꞩ', "s" )
    , ( 'ꞅ', "s" )
    , ( 'ẛ', "s" )
    , ( 't', "t" )
    , ( 'ⓣ', "t" )
    , ( 'ｔ', "t" )
    , ( 'ṫ', "t" )
    , ( 'ẗ', "t" )
    , ( 'ť', "t" )
    , ( 'ṭ', "t" )
    , ( 'ț', "t" )
    , ( 'ţ', "t" )
    , ( 'ṱ', "t" )
    , ( 'ṯ', "t" )
    , ( 'ŧ', "t" )
    , ( 'ƭ', "t" )
    , ( 'ʈ', "t" )
    , ( 'ⱦ', "t" )
    , ( 'ꞇ', "t" )
    , ( 'ꜩ', "tz" )
    , ( 'u', "u" )
    , ( 'ⓤ', "u" )
    , ( 'ｕ', "u" )
    , ( 'ù', "u" )
    , ( 'ú', "u" )
    , ( 'û', "u" )
    , ( 'ũ', "u" )
    , ( 'ṹ', "u" )
    , ( 'ū', "u" )
    , ( 'ṻ', "u" )
    , ( 'ŭ', "u" )
    , ( 'ü', "u" )
    , ( 'ǜ', "u" )
    , ( 'ǘ', "u" )
    , ( 'ǖ', "u" )
    , ( 'ǚ', "u" )
    , ( 'ủ', "u" )
    , ( 'ů', "u" )
    , ( 'ű', "u" )
    , ( 'ǔ', "u" )
    , ( 'ȕ', "u" )
    , ( 'ȗ', "u" )
    , ( 'ư', "u" )
    , ( 'ừ', "u" )
    , ( 'ứ', "u" )
    , ( 'ữ', "u" )
    , ( 'ử', "u" )
    , ( 'ự', "u" )
    , ( 'ụ', "u" )
    , ( 'ṳ', "u" )
    , ( 'ų', "u" )
    , ( 'ṷ', "u" )
    , ( 'ṵ', "u" )
    , ( 'ʉ', "u" )
    , ( 'v', "v" )
    , ( 'ⓥ', "v" )
    , ( 'ｖ', "v" )
    , ( 'ṽ', "v" )
    , ( 'ṿ', "v" )
    , ( 'ʋ', "v" )
    , ( 'ꝟ', "v" )
    , ( 'ʌ', "v" )
    , ( 'ꝡ', "vy" )
    , ( 'w', "w" )
    , ( 'ⓦ', "w" )
    , ( 'ｗ', "w" )
    , ( 'ẁ', "w" )
    , ( 'ẃ', "w" )
    , ( 'ŵ', "w" )
    , ( 'ẇ', "w" )
    , ( 'ẅ', "w" )
    , ( 'ẘ', "w" )
    , ( 'ẉ', "w" )
    , ( 'ⱳ', "w" )
    , ( 'x', "x" )
    , ( 'ⓧ', "x" )
    , ( 'ｘ', "x" )
    , ( 'ẋ', "x" )
    , ( 'ẍ', "x" )
    , ( 'y', "y" )
    , ( 'ⓨ', "y" )
    , ( 'ｙ', "y" )
    , ( 'ỳ', "y" )
    , ( 'ý', "y" )
    , ( 'ŷ', "y" )
    , ( 'ỹ', "y" )
    , ( 'ȳ', "y" )
    , ( 'ẏ', "y" )
    , ( 'ÿ', "y" )
    , ( 'ỷ', "y" )
    , ( 'ẙ', "y" )
    , ( 'ỵ', "y" )
    , ( 'ƴ', "y" )
    , ( 'ɏ', "y" )
    , ( 'ỿ', "y" )
    , ( 'z', "z" )
    , ( 'ⓩ', "z" )
    , ( 'ｚ', "z" )
    , ( 'ź', "z" )
    , ( 'ẑ', "z" )
    , ( 'ż', "z" )
    , ( 'ž', "z" )
    , ( 'ẓ', "z" )
    , ( 'ẕ', "z" )
    , ( 'ƶ', "z" )
    ]
        |> Dict.fromList
