import gleam/int
import gleam/list
import gleam/string
import utils.{arr_to_pair, list_sum, pp_day, time_it}

type Range =
  #(Int, Int)

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

fn is_fresh(range: Range, id: Int) -> Bool {
  id >= range.0 && id <= range.1
}

pub fn p1(content: String) -> Int {
  let assert Ok(#(ranges, ids)) = string.split_once(content, "\n\n")
  let ranges: List(Range) =
    ranges
    |> string.split("\n")
    |> list.map(fn(range_str) {
      string.split(range_str, "-") |> list.filter_map(int.parse) |> arr_to_pair
    })
  let ids: List(Int) = string.split(ids, "\n") |> list.filter_map(int.parse)

  let is_fresh = fn(id) { ranges |> list.any(is_fresh(_, id)) }
  ids |> list.filter(is_fresh) |> list.length()
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

fn split_range_by_edges(range: Range, edges: List(Int)) -> List(Range) {
  // one of the edges is the low, one is the high
  edges
  |> list.drop_while(fn(e) { e < range.0 })
  |> list.take_while(fn(e) { e <= range.1 })
  |> list.window_by_2()
  |> list.map(fn(edge_pair) { #(edge_pair.0, edge_pair.1) })
}

fn combine_ranges(ranges: List(Range)) -> List(Range) {
  ranges
  |> list.fold([], fn(acc: List(Range), r: Range) {
    case acc {
      [] -> [r]
      [hd, ..tail] -> {
        case hd.1 == r.0 {
          True -> [#(hd.0, r.1), ..tail]
          False -> [r, ..acc]
        }
      }
    }
  })
  |> list.reverse()
}

pub fn p2(content: String) -> Int {
  let assert Ok(#(ranges, _)) = string.split_once(content, "\n\n")
  let ranges: List(Range) =
    ranges
    |> string.split("\n")
    |> list.map(fn(range_str) {
      string.split(range_str, "-") |> list.filter_map(int.parse) |> arr_to_pair
    })
  // find all the low/highs
  let all_edges =
    ranges
    |> list.flat_map(fn(r) { [r.0, r.1] })
    |> list.sort(int.compare)

  ranges
  |> list.flat_map(fn(r) { split_range_by_edges(r, all_edges) })
  |> list.unique()
  |> list.sort(fn(r1, r2) { int.compare(r1.0, r2.0) })
  |> combine_ranges()
  |> list.map(fn(r) { r.1 - r.0 + 1 })
  |> list_sum()
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 5: Cafeteria")
  assert time_it(p1, "p1", "data/05_sample.txt") == 3
  assert time_it(p1, "p1", "data/05_input.txt") == 617
  assert time_it(p2, "p2", "data/05_sample.txt") == 14
  assert time_it(p2, "p2", "data/05_input.txt") == 338_258_295_736_104
}
