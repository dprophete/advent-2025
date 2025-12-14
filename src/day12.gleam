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
  shape_ids: List(Int),
) -> Result(LightMatrix, Nil) {
  use <- bool.guard(when: shape_ids == [], return: Ok(m))

  let assert [shape_id, ..rest] = shape_ids
  let assert Ok(shapes) = dict.get(transforms, shape_id)
  use shape <- do_until(shapes)
  use x <- do_until(list.range(0, m.width - 3))
  use y <- do_until(list.range(0, m.height - 3))
  let txed_shape = tx_shape(shape, #(x, y))
  case will_fit(m, txed_shape) {
    True -> loop1(add_shape(m, txed_shape), transforms, rest)
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

  let total_shape_sizes =
    shape_ids |> list.filter_map(dict.get(shape_sizes, _)) |> list_sum

  // do we have way too may presnets to fit?
  use <- bool.lazy_guard(
    when: total_shape_sizes > m0.width * m0.height,
    return: fn() {
      printf("~p: it will never fit - don't even try\n", [idx])
      False
    },
  )

  // is the space big enough to hold all presents in their own 3x3 box?
  let all_3by_3_boxes = { m0.width / 3 } * { m0.height / 3 }
  use <- bool.lazy_guard(
    when: all_3by_3_boxes >= shape_ids |> list.length(),
    return: fn() {
      printf("~p: we have sooooooo much space\n", [idx])
      True
    },
  )

  case loop1(m0, transforms, shape_ids) {
    Ok(final_m) -> {
      printf("~p: Fit found\n", [idx])
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
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 12: Christmas Tree Farm")
  // oh great, it takes forever with the sample data but completes in no time with the input data...
  // assert time_it(p1, "p1", "data/12_sample.txt") == 2
  assert time_it(p1, "p1", "data/12_input.txt") == 448
}
