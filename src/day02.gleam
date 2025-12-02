import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/string
import simplifile
import utils.{pp_day}

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

pub fn p1(file: String) -> Int {
  let assert Ok(content) = simplifile.read(file)
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
      let new_dial = case dir {
        L -> dial - dist
        R -> dial + dist
      }
      case new_dial % 100 {
        0 -> #(0, zeros + 1)
        n -> #(n, zeros)
      }
    })
  printf("res for ~s: ~p\n", #(file, zeros))
  zeros
}

pub fn p2(file: String) -> Int {
  let assert Ok(content) = simplifile.read(file)
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
  printf("res for ~s: ~p\n", #(file, zeros))
  zeros
}

pub fn main() {
  pp_day("Day 2: Gift Shop")
}
