import gleam/dict.{type Dict}
import gleam/function
import gleam/list
import gleam/result
import gleam/string
import v2.{type V2}

// we are testing 2 representations of the matrix: as a list of rows or as a dict of positions
// (mostly for getting familiar with sum types in gleam...)
pub type DictType {
  AsDict
  AsRows
}

pub type Matrix(a) {
  MatrixRows(rows: List(List(a)), width: Int, height: Int)
  MatrixDict(d: Dict(V2, a), width: Int, height: Int)
}

//--------------------------------------------------------------------------------
// constructors
//--------------------------------------------------------------------------------

pub fn from_rows(dt: DictType, rows: List(List(a))) -> Matrix(a) {
  let height = list.length(rows)
  let width = case list.first(rows) {
    Ok(first_row) -> list.length(first_row)
    _ -> 0
  }

  case dt {
    AsRows -> MatrixRows(rows, width, height)

    AsDict ->
      MatrixDict(
        dict.from_list(
          rows
          |> list.index_map(fn(row, y) {
            row
            |> list.index_map(fn(cell, x) { #(#(x, y), cell) })
          })
          |> list.flatten,
        ),
        width,
        height,
      )
  }
}

pub fn from_string(
  dt: DictType,
  content: String,
  parse_cell: fn(String) -> a,
) -> Matrix(a) {
  let rows =
    content
    |> string.trim_end()
    |> string.split("\n")
    |> list.map(fn(line) {
      line
      |> string.to_graphemes()
      |> list.map(parse_cell)
    })
  from_rows(dt, rows)
}

pub fn with_size(dt: DictType, width: Int, height: Int, default: a) -> Matrix(a) {
  let row = list.repeat(default, width)
  let rows = list.repeat(row, height)
  from_rows(dt, rows)
}

//--------------------------------------------------------------------------------
// transformers
//--------------------------------------------------------------------------------

pub fn without_border(dt: DictType, m: Matrix(a)) -> Matrix(a) {
  let trimmed_rows =
    m
    |> get_rows()
    |> list.drop(1)
    |> list.take(m.height - 2)
    |> list.map(fn(row) {
      row
      |> list.drop(1)
      |> list.take(m.width - 2)
    })
  from_rows(dt, trimmed_rows)
}

pub fn map(m: Matrix(a), f: fn(V2, a) -> b) -> Matrix(b) {
  case m {
    MatrixRows(rows, _, _) -> {
      let new_rows =
        rows
        |> list.index_map(fn(row, y) {
          row |> list.index_map(fn(cell, x) { f(#(x, y), cell) })
        })
      from_rows(AsRows, new_rows)
    }

    MatrixDict(d, width, height) -> {
      let new_dict = d |> dict.map_values(f)
      MatrixDict(new_dict, width, height)
    }
  }
}

//--------------------------------------------------------------------------------
// misc
//--------------------------------------------------------------------------------

pub fn get_rows(m: Matrix(a)) -> List(List(a)) {
  case m {
    MatrixRows(rows, _, _) -> rows

    MatrixDict(d, width, height) -> {
      list.range(0, height - 1)
      |> list.map(fn(y) {
        list.range(0, width - 1)
        |> list.map(fn(x) {
          dict.get(d, #(x, y)) |> result.lazy_unwrap(fn() { panic })
        })
      })
    }
  }
}

pub fn find_all(m: Matrix(a), predicate: fn(V2, a) -> Bool) -> List(V2) {
  case m {
    MatrixRows(_, _, _) -> {
      m
      |> map(fn(v, cell) {
        case predicate(v, cell) {
          True -> Ok(v)
          False -> Error(Nil)
        }
      })
      |> get_rows
      |> list.flatten
      |> list.filter_map(function.identity)
    }

    MatrixDict(d, _, _) -> d |> dict.filter(predicate) |> dict.keys()
  }
}

pub fn is_in(m: Matrix(a), v: V2) -> Bool {
  v.0 >= 0 && v.0 < m.width && v.1 >= 0 && v.1 < m.height
}

pub fn get(m: Matrix(a), at v: V2) -> Result(a, Nil) {
  case m {
    MatrixRows(rows, _, _) -> {
      case is_in(m, v) {
        True -> {
          let assert Ok(row) = rows |> list.drop(v.1) |> list.first()
          let assert Ok(value) = row |> list.drop(v.0) |> list.first()
          Ok(value)
        }
        False -> Error(Nil)
      }
    }

    MatrixDict(d, _, _) -> dict.get(d, v)
  }
}

// a little heavy... we recreate the whole matrix just to change a value
pub fn set(m: Matrix(a), at v: V2, to value: a) -> Matrix(a) {
  case m {
    MatrixRows(_, _, _) -> m |> set_all([#(v, value)])

    MatrixDict(d, width, height) -> {
      let new_dict = d |> dict.insert(v, value)
      MatrixDict(new_dict, width, height)
    }
  }
}

pub fn set_all(m: Matrix(a), vals: List(#(V2, a))) -> Matrix(a) {
  let vals = dict.from_list(vals)
  case m {
    MatrixRows(_, _, _) -> {
      m |> map(fn(v, cell) { vals |> dict.get(v) |> result.unwrap(cell) })
    }

    MatrixDict(d, width, height) -> {
      // combine with new values taking precendence
      let new_dict = dict.combine(d, vals, fn(_, val) { val })
      MatrixDict(new_dict, width, height)
    }
  }
}

pub fn neighbors(m: Matrix(a), v: V2) -> List(a) {
  v |> v2.neighbors() |> list.filter_map(get(m, _))
}

pub fn around(m: Matrix(a), v: V2) -> List(a) {
  v |> v2.around() |> list.filter_map(get(m, _))
}

pub fn pp(m: Matrix(a), pp_cell: fn(a) -> String) -> String {
  m
  |> get_rows()
  |> list.map(fn(row) {
    row
    |> list.map(pp_cell)
    |> string.join("")
  })
  |> string.join("\n")
}
