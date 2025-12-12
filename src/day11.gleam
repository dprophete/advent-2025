// import gleam/format.{printf}
import cache
import gleam/dict.{type Dict}
import gleam/list
import gleam/option
import gleam/result
import gleam/string
import utils.{list_sum, pp_day, time_it}

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

fn loop_p1(graph: Graph, node: String, path: List(String)) -> Int {
  case list.contains(path, node) {
    // loop
    True -> 0
    // reaching new node
    False -> {
      let path = [node, ..path]
      case node == "out" {
        // we made it
        True -> 1
        // not the exit yet
        False -> {
          let next_nodes = graph |> dict.get(node) |> result.unwrap([])
          next_nodes
          |> list.map(loop_p1(graph, _, path))
          |> list_sum()
        }
      }
    }
  }
}

pub fn p1(content) -> Int {
  let graph: Graph = parse_graph(content)
  loop_p1(graph, "you", [])
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

fn loop_p2(graph: Graph, node: String, dst: String) -> Int {
  case cache.get(node) {
    Ok(nb_paths) -> nb_paths
    Error(_) -> {
      case node == dst {
        // we made it
        True -> 1
        // not the exit yet
        _ -> {
          let next_nodes = graph |> dict.get(node) |> result.unwrap([])
          let res =
            next_nodes
            |> list.map(loop_p2(graph, _, dst))
            |> list_sum()
          cache.put(node, res)
          res
        }
      }
    }
  }
}

pub fn p2(content) -> Int {
  let graph: Graph = parse_graph(content)
  cache.setup()
  let svr_to_fft = loop_p2(graph, "svr", "fft")
  cache.setup()
  let fft_to_dac = loop_p2(graph, "fft", "dac")
  cache.setup()
  let dac_to_out = loop_p2(graph, "dac", "out")
  svr_to_fft * fft_to_dac * dac_to_out
}

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 8: Playground")
  assert time_it(p1, "p1", "data/11_sample.txt") == 5
  assert time_it(p1, "p1", "data/11_input.txt") == 786
  assert time_it(p2, "p2", "data/11_sample2.txt") == 2
  assert time_it(p2, "p2", "data/11_input.txt") == 495_845_045_016_588
}
