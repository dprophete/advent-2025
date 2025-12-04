import gleam/int
import gleam/list
import gleam/string
import utils.{if_then_else, int_pow, nb_digits, pp_day, time_it}

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

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

fn is_invalid_p1(nb: Int) -> Bool {
  case nb_digits(nb) {
    n if n % 2 == 0 -> {
      let p = int_pow(10, n / 2)
      let lst = nb % p
      let fst = nb / p
      fst == lst
    }
    _ -> False
  }
}

fn invalid_nbs_p1(range: Range) -> Int {
  // check all numbers in range and count invalid ones
  list.range(range.low, range.high)
  |> list.fold(0, fn(acc, nb) { if_then_else(is_invalid_p1(nb), acc + nb, acc) })
}

pub fn p1(content: String) -> Int {
  parse_line(content)
  |> list.fold(0, fn(acc, range) { acc + invalid_nbs_p1(range) })
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

fn is_invalid_p2_for_size(nb: Int, chunk: Int) -> Bool {
  let p = int_pow(10, chunk)
  check(nb % p, p, nb)
}

fn check(fst: Int, p: Int, nb1: Int) -> Bool {
  case nb1 < p {
    True -> {
      nb1 == fst
    }
    False -> {
      let nb1 = nb1 / p
      let lst = nb1 % p
      { fst == lst } && check(fst, p, nb1)
    }
  }
}

fn is_invalid_p2(nb: Int) -> Bool {
  case nb_digits(nb) {
    2 -> is_invalid_p2_for_size(nb, 1)
    3 -> is_invalid_p2_for_size(nb, 1)
    4 -> is_invalid_p2_for_size(nb, 1) || is_invalid_p2_for_size(nb, 2)
    5 -> is_invalid_p2_for_size(nb, 1)
    6 ->
      is_invalid_p2_for_size(nb, 1)
      || is_invalid_p2_for_size(nb, 2)
      || is_invalid_p2_for_size(nb, 3)
    7 -> is_invalid_p2_for_size(nb, 1)
    8 ->
      is_invalid_p2_for_size(nb, 1)
      || is_invalid_p2_for_size(nb, 2)
      || is_invalid_p2_for_size(nb, 4)
    9 -> is_invalid_p2_for_size(nb, 1) || is_invalid_p2_for_size(nb, 3)
    10 ->
      is_invalid_p2_for_size(nb, 1)
      || is_invalid_p2_for_size(nb, 2)
      || is_invalid_p2_for_size(nb, 5)
    _ -> False
  }
}

fn invalid_nbs_p2(range: Range) -> Int {
  list.range(range.low, range.high)
  |> list.fold(0, fn(acc, nb) { if_then_else(is_invalid_p2(nb), acc + nb, acc) })
}

pub fn p2(content: String) -> Int {
  parse_line(content)
  |> list.fold(0, fn(acc, range) { acc + invalid_nbs_p2(range) })
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 2: Gift Shop")
  assert time_it(p1, "p1", "data/02_sample.txt") == 1_227_775_554
  assert time_it(p1, "p1", "data/02_input.txt") == 35_367_539_282
  assert time_it(p2, "p2", "data/02_sample.txt") == 4_174_379_265
  assert time_it(p2, "p2", "data/02_input.txt") == 45_814_076_230
}
