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

pub fn without_border(m: Matrix(a)) -> Matrix(a) {
  let trimmed_rows =
    m.rows
    |> list.drop(1)
    |> list.take(m.height - 2)
    |> list.map(fn(row) {
      row
      |> list.drop(1)
      |> list.take(m.width - 2)
    })
  from_list(trimmed_rows)
}

pub fn find_all(m: Matrix(a), predicate: fn(a, V2) -> Bool) -> List(V2) {
  let m2 =
    m
    |> map(fn(cell, v) {
      case predicate(cell, v) {
        True -> Some(v)
        False -> None
      }
    })

  m2.rows
  |> list.flatten
  |> option.values
}

pub fn map(m: Matrix(a), f: fn(a, V2) -> b) -> Matrix(b) {
  let new_rows =
    m.rows
    |> list.index_map(fn(row, y) {
      row |> list.index_map(fn(cell, x) { f(cell, v2.new(x, y)) })
    })
  from_list(new_rows)
}

pub fn is_in(m: Matrix(a), v: V2) -> Bool {
  v.x >= 0 && v.x < m.width && v.y >= 0 && v.y < m.height
}

pub fn get(m: Matrix(a), at v: V2) -> Option(a) {
  case is_in(m, v) {
    True -> {
      let assert Ok(row) = m.rows |> list.drop(v.y) |> list.first()
      let assert Ok(value) = row |> list.drop(v.x) |> list.first()
      Some(value)
    }
    False -> None
  }
}

// a little heavy... we recreate the whole matrix just to change a value
pub fn set(m: Matrix(a), at v: V2, to value: a) -> Matrix(a) {
  m
  |> map(fn(cell, pos) {
    case pos == v {
      True -> value
      False -> cell
    }
  })
}

pub fn with_size(width: Int, height: Int, default: a) -> Matrix(a) {
  let row = list.repeat(default, width)
  let rows = list.repeat(row, height)
  from_list(rows)
}

pub fn neighbors(m: Matrix(a), v: V2) -> List(a) {
  v
  |> v2.neighbors()
  |> list.map(get(m, _))
  |> option.values()
}

pub fn around(m: Matrix(a), v: V2) -> List(a) {
  v
  |> v2.around()
  |> list.map(get(m, _))
  |> option.values()
}

pub fn pp(m: Matrix(a), pp_cell: fn(a) -> String) -> String {
  m.rows
  |> list.map(fn(row) {
    row
    |> list.map(pp_cell)
    |> string.join("")
  })
  |> string.join("\n")
}
