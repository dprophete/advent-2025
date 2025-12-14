import gleam/bool
import gleam/dict.{type Dict}
import gleam/format.{printf}
import gleam/function
import gleam/int
import gleam/list
import gleam/pair
import gleam/set.{type Set}
import gleam/string

import utils.{arr_to_pair, if_then_else, list_sum, pp_day, time_it}
import v2.{type V2}

type LightMatrix {
  LightMatrix(pts: Set(V2), width: Int, height: Int)
}

type Region {
  Region(size: V2, quantities: List(Int))
}

type Model {
  Model(shapes: Dict(Int, Shape), regions: List(Region))
}

fn parse_region(region: String) -> Region {
  let assert [size, quantities] = region |> string.split(": ")
  let size =
    size |> string.split("x") |> list.filter_map(int.parse) |> arr_to_pair

  let quantities: List(Int) =
    quantities |> string.split(" ") |> list.filter_map(int.parse)
  Region(size, quantities)
}

fn parse(content: String) -> Model {
  let parts = content |> string.split("\n\n")
  let assert [regions, ..shapes] = list.reverse(parts)
  let shapes = list.reverse(shapes)

  let shapes: Dict(Int, Shape) =
    shapes
    |> list.index_map(fn(shape, idx) { #(idx, parse_shape(shape)) })
    |> dict.from_list()

  let regions: List(Region) =
    regions |> string.split("\n") |> list.map(parse_region)
  Model(shapes, regions)
}

// --------------------------------------------------------------------------------
// shape
// --------------------------------------------------------------------------------

type Shape =
  Set(V2)

fn parse_shape(shape: String) -> Shape {
  let assert [_, ..lines] = shape |> string.split("\n")
  lines
  |> list.index_map(fn(line, y) {
    line
    |> string.to_graphemes()
    |> list.index_map(fn(char, x) {
      if_then_else(char == "#", Ok(#(x, y)), Error(Nil))
    })
    |> list.filter_map(function.identity)
  })
  |> list.flatten()
  |> set.from_list()
}

fn rotate_left(shape: Shape) -> Shape {
  shape |> set.map(fn(pt) { #(pt.1, 2 - pt.0) })
}

fn rot_right(shape: Shape) -> Shape {
  shape |> set.map(fn(pt) { #(2 - pt.1, pt.0) })
}

fn flip_hori(shape: Shape) -> Shape {
  shape |> set.map(fn(pt) { #(2 - pt.0, pt.1) })
}

fn flip_vert(shape: Shape) -> Shape {
  shape |> set.map(fn(pt) { #(pt.0, 2 - pt.1) })
}

fn all_transforms(shape: Shape) -> List(Shape) {
  let fh = flip_hori(shape)
  let fv = flip_vert(shape)

  let r1 = rot_right(shape)
  let fh1 = flip_hori(r1)
  let fv1 = flip_vert(r1)

  // no need to flip here since we land back on the original shapes
  let r2 = rot_right(r1)

  // no need to flip here since we land back on the r1 shapes
  let r3 = rot_right(r2)

  [shape, fh, fv, r1, fh1, fv1, r2, r3] |> list.unique()
}

fn tx_shape(shape: Shape, tx: V2) -> Shape {
  shape |> set.map(fn(pt) { #(pt.0 + tx.0, pt.1 + tx.1) })
}

fn pp_shape(shape: Shape) {
  list.range(0, 2)
  |> list.map(fn(y) {
    list.range(0, 2)
    |> list.map(fn(x) {
      case set.contains(shape, #(x, y)) {
        True -> "#"
        _ -> "."
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
}

fn pp_matrix(m: LightMatrix) {
  list.range(0, m.height - 1)
  |> list.map(fn(y) {
    list.range(0, m.width - 1)
    |> list.map(fn(x) {
      case set.contains(m.pts, #(x, y)) {
        True -> "#"
        _ -> "."
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
}

fn add_shape(m: LightMatrix, shape: Shape) -> LightMatrix {
  LightMatrix(set.union(m.pts, shape), m.width, m.height)
}

// see if shape fits in the matrix
fn will_fit(m: LightMatrix, shape: Shape) -> Bool {
  set.is_disjoint(shape, m.pts)
}

// fn get_nx_piece(
//   quantities: Dict(Int, Int),
// ) -> Result(#(Int, Dict(Int, Int)), Nil) {
//   case dict.is_empty(quantities) {
//     True -> Error(Nil)
//     False -> {
//       let assert [#(shape_id, qty), ..] = dict.to_list(quantities)
//       let new_quantities = case { qty == 1 } {
//         True -> dict.delete(quantities, shape_id)
//         False -> dict.insert(quantities, shape_id, qty - 1)
//       }
//
//       Ok(#(shape_id, new_quantities))
//     }
//   }
// }

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

pub fn do_until(
  over list: List(a),
  with fun: fn(a) -> Result(b, Nil),
) -> Result(b, Nil) {
  case list {
    [] -> Error(Nil)
    [first, ..rest] ->
      case fun(first) {
        Ok(res) -> Ok(res)
        _ -> do_until(rest, fun)
      }
  }
}

fn loop1(
  m: LightMatrix,
  transforms: Dict(Int, List(Shape)),
  shape_sizes: Dict(Int, Int),
  shape_ids: List(Int),
) -> Result(LightMatrix, Nil) {
  use <- bool.guard(when: shape_ids == [], return: Ok(m))
  let remaining_size = m.width * m.height - set.size(m.pts)

  // this is cheating !!!
  use <- bool.lazy_guard(
    when: remaining_size >= list.length(shape_ids) * 9,
    return: fn() {
      printf("More than enough space", [])
      Ok(m)
    },
  )

  let remaining_pts =
    shape_ids |> list.filter_map(dict.get(shape_sizes, _)) |> list_sum

  use <- bool.lazy_guard(when: remaining_size < remaining_pts, return: fn() {
    printf("Not enough space: ~p < ~p\n", [remaining_size, remaining_pts])
    Error(Nil)
  })

  let assert [shape_id, ..rest] = shape_ids
  let assert Ok(shapes) = dict.get(transforms, shape_id)
  use shape <- do_until(shapes)
  use x <- do_until(list.range(0, m.width - 3))
  use y <- do_until(list.range(0, m.height - 3))
  // printf("trying to place piece ~p at (~p, ~p)\n", [shape_id, x, y])
  let txed_shape = tx_shape(shape, #(x, y))
  case will_fit(m, txed_shape) {
    True -> {
      let m1 = add_shape(m, txed_shape)
      loop1(m1, transforms, shape_sizes, rest)
    }
    False -> Error(Nil)
  }
}

fn can_fit(
  idx: Int,
  region: Region,
  transforms: Dict(Int, List(Shape)),
  shape_sizes: Dict(Int, Int),
) -> Bool {
  let m0 = LightMatrix(set.new(), region.size.0, region.size.1)
  let quantities = region.quantities
  let shape_ids =
    quantities
    |> list.index_map(pair.new)
    |> list.fold([], fn(acc, el) {
      let #(shape_id, qty) = el
      list.append(acc, list.repeat(qty, shape_id))
    })

  case loop1(m0, transforms, shape_sizes, shape_ids) {
    Ok(final_m) -> {
      printf("~p: Fit found\n", [idx])
      printf("Final:\n~s\n", [pp_matrix(final_m)])
      True
    }
    Error(_) -> {
      printf("~p: No fit found\n", [idx])
      False
    }
  }
}

pub fn p1(content) -> Int {
  let model = parse(content)
  let shapes = model.shapes
  // dict: shape_id -> list of all transforms for this shape
  let transforms: Dict(Int, List(Shape)) =
    shapes |> dict.map_values(fn(_, shape) { all_transforms(shape) })
  let shape_sizes: Dict(Int, Int) =
    shapes |> dict.map_values(fn(_, shape) { set.size(shape) })

  model.regions
  |> list.index_map(pair.new)
  |> list.count(fn(el) { can_fit(el.1, el.0, transforms, shape_sizes) })
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 12: Christmas Tree Farm")
  // assert time_it(p1, "p1", "data/12_sample.txt") == 2
  assert time_it(p1, "p1", "data/12_input.txt") == 448
  // assert time_it(p2, "p2", "data/12_sample2.txt") == 2
  // assert time_it(p2, "p2", "data/12_input.txt") == 495_845_045_016_588
}
