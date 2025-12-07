import gleam/list
import matrix
import utils.{pp_day, time_it}

type Cell {
  Start
  Empty
  Splitter
  Tachyon
  X
}

fn parse_cell(s: String) -> Cell {
  case s {
    "S" -> Start
    "." -> Empty
    "^" -> Splitter
    "|" -> Tachyon
    "X" -> X
    _ -> panic as "Invalid cell character"
  }
}

fn pp_cell(cell: Cell) -> String {
  case cell {
    Start -> "S"
    Empty -> "."
    Splitter -> "^"
    Tachyon -> "|"
    X -> "X"
  }
}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

pub fn p1(content: String) -> Int {
  let m = matrix.from_string(matrix.AsDict, content, parse_cell)

  let tachyons = [m.width / 2]

  let res =
    list.range(1, m.height - 1)
    |> list.fold(#(tachyons, 1, m), fn(acc, y) {
      let #(current_tachyons, current_count, current_m) = acc

      // find splitters and split beams
      let new_tachyons =
        current_tachyons
        |> list.flat_map(fn(x) {
          case matrix.get(current_m, #(x, y)) {
            Ok(Splitter) -> [x - 1, x + 1]
            _ -> [x]
          }
        })
        |> list.unique

      // set tachyons in the new matrix
      let new_cells = new_tachyons |> list.map(fn(x) { #(#(x, y), Tachyon) })
      let new_m = current_m |> matrix.set_all(new_cells)

      #(new_tachyons, current_count, new_m)
    })
  let new_m = res.2

  // let's find all the splitters and figure out which ones were not reaches
  let splitters = matrix.find_all(new_m, fn(_, cell) { cell == Splitter })
  let nb_splits =
    splitters
    |> list.count(fn(v) {
      case matrix.get(new_m, #(v.0, v.1 - 1)) {
        Ok(Tachyon) -> True
        _ -> False
      }
    })

  nb_splits
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 6: Trash Compactor")
  assert time_it(p1, "p1", "data/07_sample.txt") == 21
  assert time_it(p1, "p1", "data/07_input.txt") == 1573
  // assert time_it(p2, "p2", "data/07_sample.txt") == 3_263_827
  // assert time_it(p2, "p2", "data/07_input.txt") == 11_950_004_808_442
}
