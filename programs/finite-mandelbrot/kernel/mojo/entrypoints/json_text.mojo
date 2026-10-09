# json_text.mojo
#
# The JSON the entrypoints print, written by hand because the objects are small
# and flat: integers, rationals as [num, den] pairs, strings and booleans. No
# float is ever formatted here.

def quoted(s: String) -> String:
    return '"' + s + '"'


def flag(b: Bool) -> String:
    return "true" if b else "false"


def ints(xs: List[Int]) -> String:
    var out = String("[")
    for i in range(len(xs)):
        if i > 0:
            out += ","
        out += String(xs[i])
    out += "]"
    return out^


def pair(a: Int, b: Int) -> String:
    return "[" + String(a) + "," + String(b) + "]"


def field(name: String, value: String) -> String:
    return quoted(name) + ":" + value


def joined(parts: List[String], open: String, close: String) -> String:
    var out = open
    for i in range(len(parts)):
        if i > 0:
            out += ","
        out += parts[i]
    out += close
    return out^


def obj(parts: List[String]) -> String:
    return joined(parts, "{", "}")


def arr(parts: List[String]) -> String:
    return joined(parts, "[", "]")
