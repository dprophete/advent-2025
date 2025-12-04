pub type Dir {
  Up
  Down
  Left
  Right
}

pub fn rot_left(dir: Dir) -> Dir {
  case dir {
    Up -> Left
    Left -> Down
    Down -> Right
    Right -> Up
  }
}

pub fn rot_right(dir: Dir) -> Dir {
  case dir {
    Up -> Right
    Right -> Down
    Down -> Left
    Left -> Up
  }
}

pub fn pp(dir: Dir) -> String {
  case dir {
    Up -> "Up"
    Down -> "Down"
    Left -> "Left"
    Right -> "Right"
  }
}
