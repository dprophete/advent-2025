import gleam/function
import gleam/list
import gleam/option.{Some}
import matrix
import utils.{if_then_else, list_sum, pp_day, time_it}
import v2

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

pub fn p1(content: String) -> Int {
  let m = matrix.from_string(content, function.identity)
  list.range(0, m.height - 1)
  |> list.map(fn(y) {
    list.range(0, m.width - 1)
    |> list.map(fn(x) {
      let v = v2.new(x, y)
      case matrix.get(m, v) {
        Some("@") -> {
          let nb_rolls =
            matrix.around(m, v)
            |> list.filter(fn(cell) { cell == "@" })
            |> list.length()
          if_then_else(nb_rolls < 4, 1, 0)
        }
        _ -> 0
      }
    })
    |> list_sum
  })
  |> list_sum
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
