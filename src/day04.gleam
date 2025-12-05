import gleam/dict
import gleam/list
import matrix.{type Matrix}
import utils.{pp_day, time_it}
import v2.{type V2}

type Cell {
  Roll
  Empty
  X
}

// fn pp_cell(cell: Cell) -> String {
//   case cell {
//     Roll -> "@"
//     Empty -> "."
//     X -> "X"
//   }
// }

fn parse_cell(s: String) -> Cell {
  case s {
    "@" -> Roll
    "." -> Empty
    "X" -> X
    _ -> panic as "Invalid cell character"
  }
}

fn can_move(m: Matrix(Cell), cell: Cell, v: V2) -> Bool {
  case cell {
    Roll -> {
      let nb_rolls =
        matrix.around(m, v)
        |> list.filter(fn(cell) { cell == Roll })
        |> list.length()
      nb_rolls < 4
    }
    _ -> False
  }
}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

pub fn p1(content: String) -> Int {
  let m = matrix.from_string(content, parse_cell)
  matrix.find_all(m, fn(cell, v) { can_move(m, cell, v) }) |> list.length()
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

fn helper(m: Matrix(Cell), total_removed: Int) -> Int {
  let movable_rolls = matrix.find_all(m, fn(cell, v) { can_move(m, cell, v) })
  let nb_removed = list.length(movable_rolls)
  let new_cells = movable_rolls |> list.map(fn(v) { #(v, X) }) |> dict.from_list
  let m_without_rolls = matrix.set_all(m, new_cells)
  case nb_removed {
    0 -> total_removed
    _ -> helper(m_without_rolls, total_removed + nb_removed)
  }
}

pub fn p2(content: String) -> Int {
  let m = matrix.from_string(content, parse_cell)
  helper(m, 0)
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 4: Printing Department")
  assert time_it(p1, "p1", "data/04_sample.txt") == 13
  assert time_it(p1, "p1", "data/04_input.txt") == 1370
  assert time_it(p2, "p2", "data/04_sample.txt") == 43
  assert time_it(p2, "p2", "data/04_input.txt") == 8437
}
