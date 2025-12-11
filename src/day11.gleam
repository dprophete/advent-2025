// import gleam/format.{printf}
import gleam/dict.{type Dict}
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import utils.{pp_day, time_it}

type Graph =
  Dict(String, List(String))

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

fn loop(
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
          |> list.flat_map(loop(graph, _, path, solutions))
        }
      }
    }
  }
}

pub fn p1(content) -> Int {
  let graph: Graph =
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

  let solutions = loop(graph, "you", [], [])
  list.length(solutions)
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 8: Playground")
  assert time_it(p1, "p1", "data/11_sample.txt") == 5
  assert time_it(p1, "p1", "data/11_input.txt") == 786
  // assert time_it(p2, "p2", "data/11_sample.txt") == 33
  // assert time_it(p2, "p2", "data/11_input.txt") == 1_351_617_690
}
