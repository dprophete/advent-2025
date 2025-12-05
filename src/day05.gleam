import gleam/int
import gleam/list
import gleam/string
import utils.{pp_day, time_it}

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

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 4: Printing Department")
  assert time_it(p1, "p1", "data/05_sample.txt") == 3
  assert time_it(p1, "p1", "data/05_input.txt") == 617
  // assert time_it(p2, "p2", "data/05_sample.txt") == 43
  // assert time_it(p2, "p2", "data/05_input.txt") == 8437
}
