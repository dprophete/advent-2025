import gleam/dict.{type Dict}
import gleam/format.{printf}
import gleam/function
import gleam/int
import gleam/list.{Continue, Stop}
import gleam/pair
import gleam/string
import matrix.{type Matrix}
import utils.{arr_to_pair, if_then_else, pp_day, time_it}
import v2.{type V2}

// type Cell {
//   Empty
//   Occupied
// }

type Region {
  Region(size: V2, quantities: Dict(Int, Int))
}

type Model {
  Model(shapes: Dict(Int, Shape), regions: List(Region))
}

// fn parse_cell(str: String) -> Cell {
//   case str == "#" {
//     True -> Occupied
//     False -> Empty
//   }
// }

fn parse_region(region: String) -> Region {
  let assert [size, quantities] = region |> string.split(": ")
  let size =
    size |> string.split("x") |> list.filter_map(int.parse) |> arr_to_pair

  let quantities: List(Int) =
    quantities |> string.split(" ") |> list.filter_map(int.parse)
  let quantities: Dict(Int, Int) =
    quantities
    |> list.index_map(fn(qty, idx) { #(idx, qty) })
    |> list.filter(fn(el) { el.1 > 0 })
    |> dict.from_list()
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
  List(V2)

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
}

fn rotate_left(shape: Shape) -> Shape {
  shape |> list.map(fn(pt) { #(pt.1, 2 - pt.0) })
}

fn rot_right(shape: Shape) -> Shape {
  shape |> list.map(fn(pt) { #(2 - pt.1, pt.0) })
}

fn flip_hori(shape: Shape) -> Shape {
  shape |> list.map(fn(pt) { #(2 - pt.0, pt.1) })
}

fn flip_vert(shape: Shape) -> Shape {
  shape |> list.map(fn(pt) { #(pt.0, 2 - pt.1) })
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
  shape |> list.map(fn(pt) { #(pt.0 + tx.0, pt.1 + tx.1) })
}

fn pp_shape(shape: Shape) {
  list.range(0, 2)
  |> list.map(fn(y) {
    list.range(0, 2)
    |> list.map(fn(x) {
      case list.find(shape, fn(pt) { pt == #(x, y) }) {
        Ok(_) -> "#"
        _ -> "."
      }
    })
    |> string.join("")
  })
  |> string.join("\n")
}

fn add_shape_at(m: Matrix(String), shape: Shape) -> Matrix(String) {
  shape
  |> list.map(fn(pt) { #(pt, "#") })
  |> matrix.set_all(m, _)
}

// try all the shape transforms to see if it will fit in the matrix
fn will_fit_with_transforms_and_txs(
  m: Matrix(String),
  shape: Shape,
) -> Result(Shape, Nil) {
  all_transforms(shape)
  |> list.fold_until(Error(Nil), fn(acc, transformed) {
    case will_fit_with_txs(m, transformed) {
      Ok(tx) -> Stop(Ok(tx_shape(transformed, tx)))
      Error(_) -> Continue(acc)
    }
  })
}

fn will_fit_with_txs(m: Matrix(String), shape: Shape) -> Result(V2, Nil) {
  list.range(0, m.width - 3)
  |> list.fold_until(Error(Nil), fn(acc, x) {
    case
      list.range(0, m.height - 3)
      |> list.find(fn(y) { will_fit(m, tx_shape(shape, #(x, y))) })
    {
      Ok(y) -> Stop(Ok(#(x, y)))
      Error(_) -> Continue(acc)
    }
  })
}

fn will_fit_with_transforms(
  m: Matrix(String),
  shape: Shape,
) -> Result(Shape, Nil) {
  shape
  |> all_transforms()
  |> list.find(fn(transformed) { will_fit(m, transformed) })
}

// see if shape fits in the matrix
fn will_fit(m: Matrix(String), shape: Shape) -> Bool {
  shape
  |> list.all(fn(pt) {
    case matrix.get(m, pt) {
      Ok(cell) -> cell == "."
      _ -> False
    }
  })
}

fn get_nx_piece(
  quantities: Dict(Int, Int),
) -> Result(#(Int, Dict(Int, Int)), Nil) {
  case dict.is_empty(quantities) {
    True -> Error(Nil)
    False -> {
      let assert [#(shape_id, qty), ..] = dict.to_list(quantities)
      let new_quantities = case { qty == 1 } {
        True -> dict.delete(quantities, shape_id)
        False -> dict.insert(quantities, shape_id, qty - 1)
      }

      Ok(#(shape_id, new_quantities))
    }
  }
}

// --------------------------------------------------------------------------------
// p1
// --------------------------------------------------------------------------------

fn loop1(
  m: Matrix(String),
  shapes: Dict(Int, Shape),
  quantities: Dict(Int, Int),
) -> Result(Matrix(String), Nil) {
  case get_nx_piece(quantities) {
    // that as the last piece
    Error(_) -> Ok(m)

    Ok(#(shape_id, new_quantities)) -> {
      let assert Ok(shape) = dict.get(shapes, shape_id)
      printf("Trying to fit shape\n~s\n", [pp_shape(shape)])
      case will_fit_with_transforms_and_txs(m, shape) {
        Error(_) -> Error(Nil)

        Ok(fit_shape) -> {
          let m1 = add_shape_at(m, fit_shape)
          loop1(m1, shapes, new_quantities)
        }
      }
    }
  }
}

fn can_fit(idx: Int, region: Region, shapes: Dict(Int, Shape)) -> Bool {
  let m0 = matrix.with_size(matrix.AsDict, region.size.0, region.size.1, ".")

  let quantities = region.quantities
  case loop1(m0, shapes, quantities) {
    Ok(final_m) -> {
      printf("~p: Fit found\n", [idx])
      // printf("Final:\n~s\n", [matrix.pp(final_m, function.identity)])
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
  let assert [r0, r1, _] = model.regions
  // can_fit(0, r0, shapes)
  can_fit(1, r1, shapes)
  // model.regions
  // |> list.index_map(pair.new)
  // |> list.count(fn(el) { can_fit(el.1, el.0, shapes) })
  2
}

// --------------------------------------------------------------------------------
// p2
// --------------------------------------------------------------------------------

// --------------------------------------------------------------------------------
// main
// --------------------------------------------------------------------------------

pub fn main() {
  pp_day("Day 12: Christmas Tree Farm")
  assert time_it(p1, "p1", "data/12_sample.txt") == 2
  // assert time_it(p1, "p1", "data/12_input.txt") == 786
  // assert time_it(p2, "p2", "data/12_sample2.txt") == 2
  // assert time_it(p2, "p2", "data/12_input.txt") == 495_845_045_016_588
}
