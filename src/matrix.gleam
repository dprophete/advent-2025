import gleam/list
import gleam/option.{type Option, None, Some}
import gleam/string
import v2.{type V2}

pub type Matrix(a) {
  Matrix(rows: List(List(a)), width: Int, height: Int)
}

pub fn from_list(rows: List(List(a))) -> Matrix(a) {
  let height = list.length(rows)
  let width = case list.first(rows) {
    Ok(first_row) -> list.length(first_row)
    _ -> 0
  }
  Matrix(rows, width, height)
}

pub fn from_string(content: String, parse_cell: fn(String) -> a) -> Matrix(a) {
  let rows =
    content
    |> string.trim_end()
    |> string.split("\n")
    |> list.map(fn(line) {
      line
      |> string.to_graphemes()
      |> list.map(parse_cell)
    })
  from_list(rows)
}

pub fn without_border(matrix: Matrix(a)) -> Matrix(a) {
  let trimmed_rows =
    matrix.rows
    |> list.drop(1)
    |> list.take(matrix.height - 2)
    |> list.map(fn(row) {
      row
      |> list.drop(1)
      |> list.take(matrix.width - 2)
    })
  from_list(trimmed_rows)
}

// pub fn find_first(matrix: Matrix(a), value: a) -> Option(V2) {
//   matrix.rows
//   |> list.f
//   todo
// matrix.rows
// |> list.indexed()
// |> list.flat_map(fn({row, y}) {
//   row
//   |> list.indexed()
//   |> list.filter_map(fn({cell, x}) {
//     if predicate(cell) {
//       Some({x: x, y: y})
//     } else {
//       None
//     }
//   })
// })
// |> list.head()
// }

pub fn is_in(matrix: Matrix(a), v: V2) -> Bool {
  v.x >= 0 && v.x < matrix.width && v.y >= 0 && v.y < matrix.height
}

pub fn get(matrix: Matrix(a), at v: V2) -> Option(a) {
  case is_in(matrix, v) {
    True -> {
      let assert Ok(row) = matrix.rows |> list.drop(v.y) |> list.first()
      let assert Ok(value) = row |> list.drop(v.x) |> list.first()
      Some(value)
    }
    False -> None
  }
}

pub fn with_size(width: Int, height: Int, default: a) -> Matrix(a) {
  let row = list.repeat(default, width)
  let rows = list.repeat(row, height)
  from_list(rows)
}

pub fn neighbors(matrix: Matrix(a), v: V2) -> List(a) {
  v
  |> v2.neighbors()
  |> list.map(get(matrix, _))
  |> option.values()
}

pub fn around(matrix: Matrix(a), v: V2) -> List(a) {
  v
  |> v2.around()
  |> list.map(get(matrix, _))
  |> option.values()
}

pub fn pp(matrix: Matrix(a), pp_cell: fn(a) -> String) -> String {
  matrix.rows
  |> list.map(fn(row) {
    row
    |> list.map(pp_cell)
    |> string.join("")
  })
  |> string.join("\n")
}
