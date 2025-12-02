import gleam/int
import gleam/list
import gleam/result
import gleam/string
import simplifile

type LR {
  L
  R
}

type Line {
  Line(dir: LR, dist: Int)
}

fn parse_line(line: String) -> Result(Line, String) {
  let dir_char = string.slice(line, 0, 1)
  let dist_str = string.slice(line, 1, string.length(line))

  use dir <- result.try(case dir_char {
    "L" -> Ok(L)
    "R" -> Ok(R)
    _ -> Error("Invalid direction")
  })

  use dist <- result.try(
    int.parse(dist_str) |> result.replace_error("Invalid distance" <> dist_str),
  )

  Ok(Line(dir: dir, dist: dist))
}

pub fn p1(file: String) {
  use content <- result.try(simplifile.read(file))
  let lines =
    content
    |> string.trim_end()
    |> string.split("\n")
    |> list.filter_map(parse_line)

  let start = #(50, 0)
  let #(_, zeros) =
    lines
    |> list.fold(start, fn(acc, line) {
      let #(dial, zeros) = acc
      let new_dial = case line {
        Line(dir: L, dist:) -> dial - dist
        Line(dir: R, dist:) -> dial + dist
      }
      case new_dial % 100 {
        0 -> #(0, zeros + 1)
        n -> #(n, zeros)
      }
    })
  echo zeros
  Ok(zeros)
}

pub fn main() {
  assert p1("data/sample.txt") == Ok(3)
  assert p1("data/input.txt") == Ok(1129)
}
