import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import utils.{list_sum, pp_day, time_it}

type Bank {
  Bank(batteries: List(Int))
}

fn parse_content(content: String) -> List(Bank) {
  content
  |> string.split("\n")
  |> list.map(parse_line)
}

fn parse_line(line: String) -> Bank {
  Bank(batteries: line |> string.split("") |> list.filter_map(int.parse))
}

// comparator to sort arrays of #(el:Int, idx:Int) by the first element
// (basically you can use list.index_map first and then use this comparator)
fn comp_with_idx(v1: #(Int, Int), v2: #(Int, Int)) {
  int.compare(v1.0, v2.0)
}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

pub fn p1(file: String) -> Int {
  parse_content(file)
  |> list.map(fn(bank) {
    let Bank(batteries) = bank
    let batteries_with_idx = batteries |> list.index_map(pair.new)

    let assert Ok(#(v1, i1)) =
      batteries_with_idx
      |> list.take(list.length(batteries) - 1)
      |> list.max(comp_with_idx)

    let assert Ok(#(v2, _)) =
      batteries_with_idx |> list.drop(i1 + 1) |> list.max(comp_with_idx)

    v1 * 10 + v2
  })
  |> list_sum()
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

pub fn p2(file: String) -> Int {
  parse_content(file)
  |> list.map(fn(bank) {
    let Bank(batteries) = bank

    list.range(12, 1)
    |> list.fold(#(batteries, 0), fn(acc, remaining) {
      let #(lst, res) = acc
      let lst_with_idx = lst |> list.index_map(pair.new)
      let assert Ok(#(v, i)) =
        lst_with_idx
        |> list.take(list.length(lst) + 1 - remaining)
        |> list.max(comp_with_idx)
      #(lst |> list.drop(i + 1), res * 10 + v)
    })
    |> pair.second()
  })
  |> list_sum()
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 3: Lobby")
  assert time_it(p1, "p1", "data/03_sample.txt") == 357
  assert time_it(p1, "p1", "data/03_input.txt") == 17_179
  assert time_it(p2, "p2", "data/03_sample.txt") == 3_121_910_778_619
  assert time_it(p2, "p2", "data/03_input.txt") == 170_025_781_683_941
}
