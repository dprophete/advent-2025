import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/set.{type Set}
import gleam/string
import utils.{int_pow, list_sum, pp_day, time_it}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

type Machine1 {
  Machine1(lights: Int, buttons: List(Int))
}

// (2,3) -> 2^2 + 2^3 = 4 + 8 = 12
fn parse_btn_p1(str: String) -> Int {
  str
  |> string.slice(1, string.length(str) - 2)
  |> string.split(",")
  |> list.filter_map(int.parse)
  |> list.map(fn(nb) { int_pow(2, nb) })
  |> list_sum
}

// .###.# -> 2^1 + 2^2 + 2^3 + 2^5 = 1 + 4 + 8 + 32 = 46
fn parse_lights_p1(str: String) -> Int {
  str
  |> string.to_graphemes()
  |> list.index_map(fn(ch, idx) {
    case ch {
      "#" -> int_pow(2, idx)
      _ -> 0
    }
  })
  |> list_sum
}

fn invoke_btns_p1(val: Int, btns: List(Int)) -> List(Int) {
  btns |> list.map(fn(btn) { int.bitwise_exclusive_or(val, btn) })
}

fn loop_p1(
  vals: List(Int),
  btns: List(Int),
  visited: Set(Int),
  rounds: Int,
) -> Int {
  let next_vals =
    vals
    |> list.flat_map(invoke_btns_p1(_, btns))
    |> list.unique()
    |> list.filter(fn(nb) { !set.contains(visited, nb) })

  let next_visited = next_vals |> list.fold(visited, set.insert)

  case list.any(next_vals, fn(nb) { nb == 0 }) {
    True -> rounds
    False -> loop_p1(next_vals, btns, next_visited, rounds + 1)
  }
}

pub fn p1(content) -> Int {
  let assert Ok(re_machine) = regexp.from_string("\\[(.*)\\] (.*) {(.*)}")

  let machines: List(Machine1) =
    content
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [match] = regexp.scan(re_machine, line)
      let assert [Some(lights), Some(buttons), _] = match.submatches
      let lights = parse_lights_p1(lights)
      let buttons = buttons |> string.split(" ") |> list.map(parse_btn_p1)
      Machine1(lights, buttons)
    })

  machines
  |> list.map(fn(machine) {
    loop_p1([machine.lights], machine.buttons, set.new(), 1)
  })
  |> list_sum()
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

type Machine2 {
  Machine2(buttons: List(Int), joltage: List(Int))
}

pub fn p2(content) -> Int {
  let assert Ok(re_machine) = regexp.from_string("\\[(.*)\\] (.*) {(.*)}")

  let machines: List(Machine2) =
    content
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [match] = regexp.scan(re_machine, line)
      let assert [_, Some(buttons), Some(joltage)] = match.submatches
      let joltage = joltage |> string.split(",") |> list.filter_map(int.parse)
      let buttons = buttons |> string.split(" ") |> list.map(parse_btn_p1)
      Machine2(buttons, joltage)
    })

  // machines
  // |> list.map(fn(machine) {
  //   loop_p1([machine.lights], machine.buttons, set.new(), 1)
  // })
  // |> list_sum()
  10
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 8: Playground")
  assert time_it(p1, "p1", "data/10_sample.txt") == 7
  assert time_it(p1, "p1", "data/10_input.txt") == 488
  // assert time_it(p2, "p2", "data/10_sample.txt") == 33
  // assert time_it(p2, "p2", "data/10_input.txt") == 1_351_617_690
}
