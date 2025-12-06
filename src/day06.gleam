import gleam/int
import gleam/list
import gleam/pair
import gleam/string
import utils.{
  if_then_else, int_parse, list_sum, pp_day, split_on_spaces, time_it,
}

type Op {
  Add
  Mul
}

fn parse_op(op_str: String) -> Op {
  case op_str {
    "+" -> Add
    "*" -> Mul
    _ -> panic
  }
}

fn eval_op(a: Int, op: Op, b: Int) -> Int {
  case op {
    Add -> a + b
    Mul -> a * b
  }
}

fn eval_line(op: Op, nbs: List(Int)) -> Int {
  nbs
  |> list.fold(if_then_else(op == Add, 0, 1), fn(acc, nb) {
    eval_op(acc, op, nb)
  })
}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

pub fn p1(content: String) -> Int {
  let lines = string.split(content, "\n")
  let assert [ops, ..rest] = list.reverse(lines)
  let rest = list.reverse(rest)

  let ops: List(Op) = ops |> split_on_spaces |> list.map(parse_op)
  let lines_of_nbs: List(List(Int)) =
    rest
    |> list.map(fn(line) {
      line |> split_on_spaces |> list.filter_map(int.parse)
    })
    |> list.transpose()

  list.zip(ops, lines_of_nbs)
  |> list.map(fn(tuple) { eval_line(tuple.0, tuple.1) })
  |> list_sum()
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

pub fn p2(content: String) -> Int {
  let lines = string.split(content, "\n")
  let assert [ops, ..rest] = list.reverse(lines)
  let rest = list.reverse(rest)

  let ops: List(Op) =
    ops |> split_on_spaces |> list.map(parse_op) |> list.reverse()

  let all_nbs_as_strings: List(String) =
    rest
    |> list.map(string.to_graphemes)
    |> list.transpose()
    |> list.map(string.join(_, ""))
    |> list.map(string.trim)

  // at this point, all_nbs_as_strings is going to be ["234", "23", "43", "", "23", "53", "", ...]
  // basically a "" means that it's a new group of numbers
  let all_groups =
    all_nbs_as_strings
    |> list.append([""])
    |> list.fold(#([], []), fn(acc, el) {
      let #(groups, current_group) = acc
      case el {
        "" -> #([current_group, ..groups], [])
        _ -> #(groups, [int_parse(el), ..current_group])
      }
    })
    |> pair.first

  list.zip(ops, all_groups)
  |> list.map(fn(tuple) { eval_line(tuple.0, tuple.1) })
  |> list_sum()
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 6: Trash Compactor")
  assert time_it(p1, "p1", "data/06_sample.txt") == 4_277_556
  assert time_it(p1, "p1", "data/06_input.txt") == 6_299_564_383_938
  assert time_it(p2, "p2", "data/06_sample.txt") == 3_263_827
  assert time_it(p2, "p2", "data/06_input.txt") == 11_950_004_808_442
}
