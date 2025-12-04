import gleam/function
import gleam/list
import matrix
import utils.{pp_day, time_it}
import v2.{type V2}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

pub fn p1(content: String) -> Int {
  let m = matrix.from_string(content, function.identity)

  let can_move = fn(cell: String, v: V2) -> Bool {
    case cell {
      "@" -> {
        let nb_rolls =
          matrix.around(m, v)
          |> list.filter(fn(cell) { cell == "@" })
          |> list.length()
        nb_rolls < 4
      }
      _ -> False
    }
  }

  matrix.find_all(m, can_move) |> list.length()
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 3: Lobby")
  assert time_it(p1, "p1", "data/04_sample.txt") == 13
  assert time_it(p1, "p1", "data/04_input.txt") == 1370
  // assert time_it(p2, "p2", "data/04_sample.txt") == 3_121_910_778_619
  // assert time_it(p2, "p2", "data/04_input.txt") == 170_025_781_683_941
}
