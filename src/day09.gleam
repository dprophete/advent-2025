// import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/pair
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

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 8: Playground")
  assert time_it(p1, "p1", "data/09_sample.txt") == 50
  assert time_it(p1, "p1", "data/09_input.txt") == 4_745_816_424
  // assert time_it(p2, "p2", "data/09_sample.txt") == 25_272
  // assert time_it(p2, "p2", "data/09_input.txt") == 3_926_518_899
}
