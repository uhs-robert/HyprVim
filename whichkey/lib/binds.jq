def normalize_key(key; modmask):
  ((modmask % 2) == 1) as $shift |
  (((modmask / 4 | floor) % 2) == 1) as $ctrl |
  (((modmask / 8 | floor) % 2) == 1) as $alt |
  (((modmask / 64 | floor) % 2) == 1) as $super |
  (key
    | gsub("SLASH"; "/") | gsub("BACKSLASH"; "\\\\")
    | gsub("COMMA"; ",") | gsub("PERIOD"; ".")
    | gsub("SEMICOLON"; ";") | gsub("APOSTROPHE"; "'")
    | gsub("GRAVE"; "`") | gsub("BRACKETLEFT"; "[") | gsub("BRACKETRIGHT"; "]")
    | gsub("MINUS"; "-") | gsub("EQUAL"; "=")
    | gsub("ESCAPE"; "ESC") | gsub("RETURN"; "RET") | gsub("BACKSPACE"; "BS")
    | gsub("tab"; "TAB")
  ) as $k |
  if (($shift or $ctrl or $alt or $super) | not) then
    if ($k | test("^[a-zA-Z]$")) then ($k | ascii_downcase) else $k end
  else
    if $shift and (($ctrl or $alt or $super) | not) then
      if ($k | test("^[a-zA-Z]$")) then ($k | ascii_upcase)
      else
        (($k
          | gsub("^1$"; "!") | gsub("^2$"; "@") | gsub("^3$"; "#")
          | gsub("^4$"; "$") | gsub("^5$"; "%") | gsub("^6$"; "^")
          | gsub("^7$"; "&") | gsub("^8$"; "*") | gsub("^9$"; "(")
          | gsub("^0$"; ")") | gsub("^-$"; "_") | gsub("^=$"; "+")
          | gsub("^\\[$"; "{") | gsub("^\\]$"; "}") | gsub("^\\\\$"; "|")
          | gsub("^;$"; ":") | gsub("^,$"; "<")
          | gsub("^\\.$"; ">") | gsub("^/$"; "?")
        ) as $translated
        | if (($translated | test("^[a-zA-Z0-9]$")) | not) and ($translated == $k) then
            ("S-" + $translated)
          else
            $translated
          end)
      end
    else
      (if $ctrl  then "C-" else "" end) +
      (if $alt   then "A-" else "" end) +
      (if $super then "M-" else "" end) +
      (if $shift then "S-" else "" end) +
      $k
    end
  end;

[ .[]
  | select(
      if $sm == "GLOBAL" then (.submap // "") == ""
      else (.submap // "") == $sm end
    )
  | select((.description // "") != "")
  | {
      key:   normalize_key(.key // ""; .modmask // 0),
      desc:  (.description // ""),
      class: (if (.description // "") | startswith("+") then "is-submap" else "" end)
    }
]
| (map(select(.key == "ESC"))) as $esc
| (map(select(.key != "ESC" and (.key | test("C-|A-|M-|S-"))))) as $mods
| (map(select(.key != "ESC" and (.key | test("C-|A-|M-|S-") | not) and (.key | test("^[a-zA-Z]$"))))) as $letters
| (map(select(.key != "ESC" and (.key | test("C-|A-|M-|S-") | not) and (.key | test("^[a-zA-Z]$") | not)))) as $special
| ($letters | sort_by(.key | ascii_downcase)) + ($special | sort_by(.key)) + ($mods | sort_by(.key)) + $esc
