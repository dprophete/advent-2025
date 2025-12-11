import gleam/dict.{type Dict}
import gleam/format.{printf}
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import utils.{pp_day, time_it}

type Graph =
  Dict(String, List(String))

fn parse_graph(content: String) -> Graph {
  content
  |> string.split("\n")
  |> list.fold(dict.new(), fn(acc: Graph, line) {
    let assert [input, outputs] = string.split(line, ": ")
    let outputs = string.split(outputs, " ")
    acc
    |> dict.upsert(input, fn(x) {
      let existing_set = x |> option.unwrap([])
      list.append(existing_set, outputs)
    })
  })
}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

fn loop_p1(
  graph: Graph,
  node: String,
  path: List(String),
  solutions: List(List(String)),
) -> List(List(String)) {
  case list.contains(path, node) {
    // loop
    True -> solutions
    // reaching new node
    False -> {
      let path = [node, ..path]
      case node == "out" {
        // we made it
        True -> [path, ..solutions]
        // not the exit yet
        False -> {
          let next_nodes = graph |> dict.get(node) |> result.unwrap([])
          next_nodes
          |> list.flat_map(loop_p1(graph, _, path, solutions))
        }
      }
    }
  }
}

pub fn p1(content) -> Int {
  let graph: Graph = parse_graph(content)
  let solutions = loop_p1(graph, "you", [], [])
  list.length(solutions)
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

fn loop_p2(
  graph: Graph,
  node: String,
  path: List(String),
  solutions: List(List(String)),
) -> List(List(String)) {
  printf("exploring node ~s with path ~p\n", #(node, list.length(path)))
  let move_on = fn(new_path) {
    let next_nodes = graph |> dict.get(node) |> result.unwrap([])
    next_nodes
    |> list.flat_map(loop_p2(graph, _, new_path, solutions))
  }

  case list.contains(path, node) {
    // loop
    True -> solutions
    // reaching new node
    False -> {
      let new_path = [node, ..path]
      case node {
        "dac" ->
          case list.contains(path, "fft") {
            True -> move_on(new_path)
            False -> solutions
          }
        // we made it
        "out" -> {
          case list.contains(path, "fft") && list.contains(path, "dac") {
            True -> {
              printf("Found solution\n", [])
              [new_path, ..solutions]
            }
            False -> solutions
          }
        }
        // not the exit yet
        _ -> move_on(new_path)
      }
    }
  }
}

pub fn p2(content) -> Int {
  let graph: Graph = parse_graph(content)
  let solutions = loop_p2(graph, "svr", [], [])
  list.length(solutions)
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 8: Playground")
  // assert time_it(p1, "p1", "data/11_sample.txt") == 5
  // assert time_it(p1, "p1", "data/11_input.txt") == 786
  // assert time_it(p2, "p2", "data/11_sample2.txt") == 2
  assert time_it(p2, "p2", "data/11_input.txt") == 1_351_617_690
}
