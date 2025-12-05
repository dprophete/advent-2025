import gleam/int
import gleam/list
import gleam/string
import utils.{list_sum, pp_day, time_it}

type Range {
  Range(low: Int, high: Int)
}

fn parse_range(line: String) -> Range {
  let assert [low, high] = string.split(line, "-") |> list.filter_map(int.parse)
  Range(low: low, high: high)
}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

fn is_fresh(range: Range, id: Int) -> Bool {
  id >= range.low && id <= range.high
}

pub fn p1(content: String) -> Int {
  let assert Ok(#(ranges, ids)) = string.split_once(content, "\n\n")
  let ranges: List(Range) =
    ranges
    |> string.split("\n")
    |> list.map(parse_range)
  let ids: List(Int) = string.split(ids, "\n") |> list.filter_map(int.parse)

  let is_fresh = fn(id) {
    ranges |> list.any(fn(range) { is_fresh(range, id) })
  }
  ids |> list.filter(is_fresh) |> list.length()
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

fn split_range_by_edges(range: Range, edges: List(Int)) -> List(Range) {
  // one of the edges is the low, one is the high
  edges
  |> list.drop_while(fn(e) { e < range.low })
  |> list.take_while(fn(e) { e <= range.high })
  |> list.window_by_2()
  |> list.map(fn(edge_pair) { Range(low: edge_pair.0, high: edge_pair.1) })
}

fn combine_ranges(ranges: List(Range)) -> List(Range) {
  ranges
  |> list.fold([], fn(acc: List(Range), r: Range) {
    case acc {
      [] -> [r]
      [hd, ..tail] -> {
        case hd.high == r.low {
          True -> [Range(low: hd.low, high: r.high), ..tail]
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
    |> list.map(parse_range)
  // find all the low/highs
  let all_edges =
    ranges
    |> list.flat_map(fn(r) { [r.low, r.high] })
    |> list.sort(int.compare)

  ranges
  |> list.flat_map(fn(r) { split_range_by_edges(r, all_edges) })
  |> list.unique()
  |> list.sort(fn(r1, r2) { int.compare(r1.low, r2.low) })
  |> combine_ranges()
  |> list.map(fn(r) { r.high - r.low + 1 })
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
