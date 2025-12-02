import gleam/int
import gleam/list
import gleam/string
import utils.{if_then_else, pp_day, time_it}

type LR {
  L
  R
}

type Line {
  Line(dir: LR, dist: Int)
}

fn parse_line(line: String) -> Line {
  let dir_char = string.slice(line, 0, 1)
  let dist_str = string.slice(line, 1, string.length(line))

  let dir = case dir_char {
    "L" -> L
    "R" -> R
    _ -> panic as "Invalid direction"
  }

  let assert Ok(dist) = int.parse(dist_str)

  Line(dir: dir, dist: dist)
}

pub fn p1(content) -> Int {
  let lines =
    content
    |> string.trim_end()
    |> string.split("\n")
    |> list.map(parse_line)

  let start = #(50, 0)
  let #(_, zeros) =
    lines
    |> list.fold(start, fn(acc, line) {
      let #(dial, zeros) = acc
      let Line(dir:, dist:) = line
      let new_dial = if_then_else(dir == L, dial - dist, dial + dist)
      case new_dial % 100 {
        0 -> #(0, zeros + 1)
        n -> #(n, zeros)
      }
    })
  zeros
}

pub fn p2(content: String) -> Int {
  let lines =
    content
    |> string.trim_end()
    |> string.split("\n")
    |> list.map(parse_line)

  let start = #(50, 0)
  let #(_, zeros) =
    lines
    |> list.fold(start, fn(acc, line) {
      let #(dial, zeros) = acc
      let Line(dir:, dist:) = line
      let nb_full_rots = dist / 100
      let sign_dist = case dir {
        L -> -{ dist % 100 }
        R -> dist % 100
      }
      let extra = case dial, dial + sign_dist {
        0, _ -> 0
        _, n if n >= 100 -> 1
        _, n if n <= 0 -> 1
        _, _ -> 0
      }
      #({ dial + sign_dist + 100 } % 100, zeros + nb_full_rots + extra)
    })
  zeros
}

pub fn main() {
  pp_day("Day 1: Secret Entrance")
  assert time_it(p1, "p1", "data/01_sample.txt") == 3
  assert time_it(p1, "p1", "data/01_input.txt") == 1129
  assert time_it(p2, "p2", "data/01_sample.txt") == 6
  assert time_it(p2, "p2", "data/01_input.txt") == 6638
}
