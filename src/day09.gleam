// import gleam/format.{printf}
import gleam/dict.{type Dict}
import gleam/int
import gleam/list
import gleam/result
import gleam/set.{type Set}
import gleam/string
import utils.{arr_to_pair, pp_day, time_it}
import v2.{type V2}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

pub fn area_between(pos1: V2, pos2: V2) -> Int {
  let dx = int.absolute_value(pos1.0 - pos2.0) + 1
  let dy = int.absolute_value(pos1.1 - pos2.1) + 1
  dx * dy
}

pub fn p1(content) -> Int {
  let vecs: List(V2) =
    content
    |> string.split("\n")
    |> list.map(fn(line) {
      line |> string.split(",") |> list.filter_map(int.parse) |> arr_to_pair
    })

  vecs
  |> list.combination_pairs()
  |> list.fold(-1, fn(acc, pairs) {
    let area = area_between(pairs.0, pairs.1)
    int.max(area, acc)
  })
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

pub fn p2(content) -> Int {
  let vecs: List(V2) =
    content
    |> string.split("\n")
    |> list.map(fn(line) {
      line |> string.split(",") |> list.filter_map(int.parse) |> arr_to_pair
    })
  let assert [first, second] = vecs |> list.take(2)
  // we want to split this list in list of vertical lines, so let's make sure we don't start with a horizontal line
  let vecs = case first.0 == second.0 {
    True -> vecs
    False -> vecs |> list.drop(1) |> list.append([first])
  }

  // let's find all the relevant y
  let all_ys: List(Int) =
    vecs |> list.map(fn(v) { v.1 }) |> list.unique() |> list.sort(int.compare)
  let all_ys_set: Set(Int) = all_ys |> set.from_list()

  // let's get all the vertical lines
  let lines: List(#(V2, V2)) =
    vecs |> list.sized_chunk(2) |> list.map(arr_to_pair)

  // for each line, we are going to keep a min/max, so we end up with a dict of y -> #(min_x, max_x)
  let min_max_per_y =
    lines
    |> list.fold(dict.new(), fn(acc: Dict(Int, #(Int, Int)), line) {
      let #(pt1, pt2) = line
      let #(pt1, pt2) = case pt1.1 > pt2.1 {
        True -> #(pt2, pt1)
        False -> #(pt1, pt2)
      }
      list.range(pt1.1, pt2.1)
      |> list.fold(acc, fn(acc2, y) {
        case all_ys_set |> set.contains(y) {
          False -> acc2
          True -> {
            let #(min_x, max_x) =
              dict.get(acc2, y) |> result.unwrap(#(1_000_000, 0))
            let new_min = min_x |> int.min(pt1.0) |> int.min(pt2.0)
            let new_max = max_x |> int.max(pt1.0) |> int.max(pt2.0)
            acc2 |> dict.insert(y, #(new_min, new_max))
          }
        }
      })
    })

  let is_in_between = fn(x0: Int, x1: Int, y: Int) {
    let assert Ok(#(min_x, max_x)) = min_max_per_y |> dict.get(y)
    x0 >= min_x && x1 <= max_x
  }

  vecs
  |> list.combination_pairs()
  // remove areas which are outside of the main shape
  |> list.filter(fn(pairs) {
    let #(pos1, pos2) = pairs
    let x0 = int.min(pos1.0, pos2.0)
    let x1 = int.max(pos1.0, pos2.0)
    let y0 = int.min(pos1.1, pos2.1)
    let y1 = int.max(pos1.1, pos2.1)

    // let's short cirtcuit by checking the first and last lines
    case is_in_between(x0, x1, pos1.1) && is_in_between(x0, x1, pos2.1) {
      True ->
        all_ys
        |> list.filter(fn(y) { y0 <= y && y <= y1 })
        |> list.all(is_in_between(x0, x1, _))
      False -> False
    }
  })
  |> list.fold(-1, fn(acc, pairs) {
    let area = area_between(pairs.0, pairs.1)
    int.max(area, acc)
  })
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 8: Playground")
  assert time_it(p1, "p1", "data/09_sample.txt") == 50
  assert time_it(p1, "p1", "data/09_input.txt") == 4_745_816_424
  assert time_it(p2, "p2", "data/09_sample.txt") == 24
  assert time_it(p2, "p2", "data/09_input.txt") == 1_351_617_690
}
