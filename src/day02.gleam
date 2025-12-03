import gleam/int
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import utils.{if_then_else, pp_day, time_it}

type Range {
  Range(low: Int, high: Int)
}

fn parse_line(line: String) -> List(Range) {
  line
  |> string.split(",")
  |> list.map(fn(range_str) {
    let assert [low, high] =
      string.split(range_str, "-") |> list.filter_map(int.parse)
    Range(low: low, high: high)
  })
}

fn is_invalid(nb: Int) -> Bool {
  let str = int.to_string(nb)
  case string.length(str) {
    n if n % 2 == 0 -> {
      let fst = string.slice(str, 0, n / 2)
      let lst = string.slice(str, n / 2, n)
      fst == lst
    }
    _ -> False
  }
}

fn invalid_nbs(range: Range) -> Int {
  // check all numbers in range and count invalid ones
  list.range(range.low, range.high)
  |> list.fold(0, fn(acc, nb) { if_then_else(is_invalid(nb), acc + nb, acc) })
}

pub fn p1(file: String) -> Int {
  let ranges: List(Range) = parse_line(file)
  ranges
  |> list.fold(0, fn(acc, range) { acc + invalid_nbs(range) })
}

pub fn p2(_file: String) -> Int {
  -1
}

pub fn main() {
  pp_day("Day 2: Gift Shop")
  assert time_it(p1, "p1", "data/02_sample.txt") == 1_227_775_554
  assert time_it(p1, "p1", "data/02_input.txt") == 35_367_539_282
}
