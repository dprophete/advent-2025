import gleam/format.{printf}
import gleam/int
import gleam/list
import gleam/option.{Some}
import gleam/regexp
import gleam/string
import utils.{int_pow, list_sum, pp_day, time_it}

type Machine {
  Machine(lights: Int, buttons: List(Int), joltage: List(Int))
}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

// (2,3) -> 2^2 + 2^3 = 4 + 8 = 12
fn parse_btn(str: String) -> Int {
  str
  |> string.slice(1, string.length(str) - 2)
  |> string.split(",")
  |> list.filter_map(int.parse)
  |> list.map(fn(nb) { int_pow(2, nb) })
  |> list_sum
}

// .###.# -> 2^0 + 2^2 + 2^3 + 2^4 = 1 + 4 + 8 + 16 = 29
fn parse_lights(str: String) -> Int {
  str
  |> string.to_graphemes()
  |> list.reverse()
  |> list.index_map(fn(ch, idx) {
    case ch {
      "#" -> int_pow(2, idx)
      _ -> 0
    }
  })
  |> list_sum
}

pub fn p1(content) -> Int {
  let assert Ok(re_machine) = regexp.from_string("\\[(.*)\\] (.*) {(.*)}")

  let machines: List(Machine) =
    content
    |> string.split("\n")
    |> list.map(fn(line) {
      let assert [match] = regexp.scan(re_machine, line)
      let assert [Some(lights), Some(buttons), Some(joltage)] = match.submatches
      let lights = parse_lights(lights)
      let joltage = joltage |> string.split(",") |> list.filter_map(int.parse)
      let buttons = buttons |> string.split(" ") |> list.map(parse_btn)
      printf("lights: ~p, buttons: ~p, joltage: ~p\n", #(
        lights,
        buttons,
        joltage,
      ))
      Machine(lights, buttons, joltage)
    })
  7
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 8: Playground")
  assert time_it(p1, "p1", "data/10_sample.txt") == 7
  // assert time_it(p1, "p1", "data/10_input.txt") == 4_745_816_424
  // assert time_it(p2, "p2", "data/10_sample.txt") == 24
  // assert time_it(p2, "p2", "data/10_input.txt") == 1_351_617_690
}
