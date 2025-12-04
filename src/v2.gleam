import dir.{type Dir, Down, Left, Right, Up}
import gleam/int

pub type V2 {
  V2(x: Int, y: Int)
}

pub const up = V2(0, -1)

pub const down = V2(0, 1)

pub const left = V2(-1, 0)

pub const right = V2(1, 0)

pub fn new(x: Int, y: Int) -> V2 {
  V2(x, y)
}

pub fn pp(v: V2) -> String {
  "(" <> int.to_string(v.x) <> ", " <> int.to_string(v.y) <> ")"
}

pub fn add(v1: V2, v2: V2) -> V2 {
  V2(v1.x + v2.x, v1.y + v2.y)
}

pub fn sub(v1: V2, v2: V2) -> V2 {
  V2(v1.x - v2.x, v1.y - v2.y)
}

pub fn scale(v: V2, factor: Int) -> V2 {
  V2(v.x * factor, v.y * factor)
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
    add(v, V2(-1, -1)),
    add(v, V2(0, -1)),
    add(v, V2(1, -1)),
    add(v, V2(-1, 0)),
    add(v, V2(1, 0)),
    add(v, V2(-1, 1)),
    add(v, V2(0, 1)),
    add(v, V2(1, 1)),
  ]
}
