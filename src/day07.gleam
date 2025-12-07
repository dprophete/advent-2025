import gleam/dict.{type Dict}
import gleam/list
import gleam/pair
import gleam/result
import matrix
import utils.{list_sum, pp_day, time_it}

type Cell {
  Start
  Empty
  Splitter
  Tachyon
}

fn parse_cell(s: String) -> Cell {
  case s {
    "S" -> Start
    "." -> Empty
    "^" -> Splitter
    "|" -> Tachyon
    _ -> panic as "Invalid cell character"
  }
}

// fn pp_cell(cell: Cell) -> String {
//   case cell {
//     Start -> "S"
//     Empty -> "."
//     Splitter -> "^"
//     Tachyon -> "|"
//   }
// }

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

pub fn p1(content: String) -> Int {
  let m = matrix.from_string(matrix.AsDict, content, parse_cell)

  let tachyons = [m.width / 2]

  list.range(1, m.height - 1)
  |> list.fold(#(tachyons, 0), fn(acc, y) {
    let #(current_tachyons, count) = acc

    // find splitters and split beams
    let new_tachyons =
      current_tachyons
      |> list.flat_map(fn(x) {
        case matrix.get(m, #(x, y)) {
          Ok(Splitter) -> [x - 1, x + 1]
          _ -> [x]
        }
      })

    let extra = list.length(new_tachyons) - list.length(current_tachyons)
    #(list.unique(new_tachyons), count + extra)
  })
  |> pair.second
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

pub fn p2(content: String) -> Int {
  let m = matrix.from_string(matrix.AsDict, content, parse_cell)

  // keep track of array of: (x, number of tachyons at x)
  let tachyons = [#(m.width / 2, 1)]

  list.range(1, m.height - 1)
  |> list.fold(tachyons, fn(current_tachyons, y) {
    // find splitters and split beams
    current_tachyons
    |> list.flat_map(fn(tachyon) {
      let #(x, count) = tachyon
      case matrix.get(m, #(x, y)) {
        Ok(Splitter) -> [#(x - 1, count), #(x + 1, count)]
        _ -> [tachyon]
      }
    })
    // combine counts at same x
    |> list.fold(dict.new(), fn(acc: Dict(Int, Int), tachyon) {
      let #(x, count) = tachyon
      let existing_count = acc |> dict.get(x) |> result.unwrap(0)
      acc |> dict.insert(x, existing_count + count)
    })
    |> dict.to_list
  })
  |> list.map(fn(tachyon) { tachyon.1 })
  |> list_sum()
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 6: Trash Compactor")
  assert time_it(p1, "p1", "data/07_sample.txt") == 21
  assert time_it(p1, "p1", "data/07_input.txt") == 1573
  assert time_it(p2, "p2", "data/07_sample.txt") == 40
  assert time_it(p2, "p2", "data/07_input.txt") == 15_093_663_987_272
}
