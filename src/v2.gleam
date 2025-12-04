import dir.{type Dir, Down, Left, Right, Up}
import gleam/int

pub type V2 =
  #(Int, Int)

pub const up = #(0, -1)

pub const down = #(0, 1)

pub const left = #(-1, 0)

pub const right = #(1, 0)

pub fn pp(v: V2) -> String {
  "(" <> int.to_string(v.0) <> ", " <> int.to_string(v.1) <> ")"
}

pub fn add(v1: V2, v2: V2) -> V2 {
  #(v1.0 + v2.0, v1.1 + v2.1)
}

pub fn sub(v1: V2, v2: V2) -> V2 {
  #(v1.0 - v2.0, v1.1 - v2.1)
}

pub fn scale(v: V2, factor: Int) -> V2 {
  #(v.0 * factor, v.1 * factor)
}

pub fn add_dir(v: V2, dir: Dir) -> V2 {
  case dir {
    Up -> add(v, up)
    Down -> add(v, down)
    Left -> add(v, left)
    Right -> add(v, right)
  }
}

pub fn from_dir(dir: Dir) -> V2 {
  case dir {
    Up -> up
    Down -> down
    Left -> left
    Right -> right
  }
}

pub fn neighbors(v: V2) -> List(V2) {
  [
    add(v, up),
    add(v, down),
    add(v, left),
    add(v, right),
  ]
}

pub fn around(v: V2) -> List(V2) {
  [
    add(v, #(-1, -1)),
    add(v, #(0, -1)),
    add(v, #(1, -1)),
    add(v, #(-1, 0)),
    add(v, #(1, 0)),
    add(v, #(-1, 1)),
    add(v, #(0, 1)),
    add(v, #(1, 1)),
  ]
}
